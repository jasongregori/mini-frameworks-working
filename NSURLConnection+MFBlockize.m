//
//  NSURLConnection+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 7/22/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "NSURLConnection+MFBlockize.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface __NSURLConnection_MFBlockize_Helper : NSObject
- (id)initWithRequest:(NSURLRequest *)request background:(BOOL)background block:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block;
- (void)cancel;
@end

@interface __NSURLConnection_MFBlockize_OnDealloc : NSObject
@property (copy) void (^performOnDeallocBlock)();
+ (id)performOnDealloc:(void (^)())block;
@end

@implementation NSURLConnection (MFBlockize)

+ (id)mfSendRequestForURL:(NSString *)url withBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    return [self mfSendRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] background:NO withBlock:block];
}

+ (id)mfSendRequest:(NSURLRequest *)request background:(BOOL)background withBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    __NSURLConnection_MFBlockize_OnDealloc *onDealloc = [__NSURLConnection_MFBlockize_OnDealloc new];
    __unsafe_unretained __NSURLConnection_MFBlockize_OnDealloc *weakOnDealloc = onDealloc;
    
    // ## the helper will run the request and call the block
    __NSURLConnection_MFBlockize_Helper *helper = [[__NSURLConnection_MFBlockize_Helper alloc] initWithRequest:request background:background block:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (block) { block(data, response, error); }
        
        // we want the helper to be released since our block was called
        // onDealloc will retain the helper until the next call
        weakOnDealloc.performOnDeallocBlock = nil;
    }];

    if (helper) {
        // ## the onDealloc object retains the helper in it's block and cancels it and releases it on dealloc
        onDealloc.performOnDeallocBlock = ^{
            [helper cancel];
        };
        return onDealloc;
    }

    return nil;
}

+ (void)mfSendWithOwner:(id)owner request:(NSURLRequest *)request background:(BOOL)background withBlock:(void (^)(id weakOwner, NSData *data, NSURLResponse *response, NSError *error))block {
    __unsafe_unretained id weakOwner = owner;
    
    // ## use the object itself as the key because we know it will be around and unique for it's lifetime
    __block __unsafe_unretained id object = nil;
    object = [self mfSendRequest:request background:background withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
        // call block
        if (block) { block(weakOwner, data, response, error); }
        // remove association
        objc_setAssociatedObject(weakOwner, (__bridge void *)object, nil, OBJC_ASSOCIATION_RETAIN);
    }];
    // associate object with owner
    objc_setAssociatedObject(owner, (__bridge void *)object, object, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - images

+ (id)mfGetImage:(NSString *)url withBlock:(void (^)(UIImage *image, NSError *error))block {
    return [self mfSendRequestForURL:url withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (block) {
            if (data) {
                block([UIImage imageWithData:data],nil);
            }
            else {
                block(nil,error);
            }
        }
    }];
}

@end

#pragma mark - __NSURLConnection_MFBlockize_Helper

@interface __NSURLConnection_MFBlockize_Helper () {
    // always accessed from main thread except on init and dealloc
    NSMutableData *_data;
    NSURLResponse *_response;
}
// potentially accessed from multiple threads (atomic)
@property (copy) void (^block)(NSData *data, NSURLResponse *response, NSError *error);
@property (strong) NSURLConnection *connection;
@property UIBackgroundTaskIdentifier taskID;

// may only be called on main thread
- (void)__startConnection:(NSURLRequest *)request;
- (void)__callBlockAndCancelWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error;
@end

@implementation __NSURLConnection_MFBlockize_Helper
@synthesize block = ___block, connection = __connection, taskID = __taskID;

- (id)initWithRequest:(NSURLRequest *)request background:(BOOL)background block:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    if ((self = [super init])) {
        _data = [NSMutableData data];
        self.block = block;
        
        // start background task
        __block UIBackgroundTaskIdentifier taskID = UIBackgroundTaskInvalid;
        if (background) {
            UIApplication *app = [UIApplication sharedApplication];
            taskID = [app beginBackgroundTaskWithExpirationHandler:^{
                [app endBackgroundTask:taskID];
            }];
        }
        self.taskID = taskID;

        // start connection
        // wait until done because we might get deallocated before startConnection finishes otherwise
        [self performSelectorOnMainThread:@selector(__startConnection:) withObject:request waitUntilDone:YES];
        
        if (!self.connection) {
            self = nil;
        }
    }
    return self;
}

// may only be called on main thread
- (void)__startConnection:(NSURLRequest *)request {
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if (!self.connection) {
        [self __callBlockAndCancelWithData:nil response:nil error:[NSError errorWithDomain:@"NSURLConnection+MFBlockize" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Failed to start connection" forKey:NSLocalizedDescriptionKey]]];
    }
}

// may only be called on main thread
- (void)__callBlockAndCancelWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    // it's possible that the block could become nil between the if and the call so get a local copy
    void (^block)(NSData *data, NSURLResponse *response, NSError *error) = self.block;
    if (block) {
        // copy the data so we're sure it won't change on the user
        block([data copy], response, error);
    }
    [self cancel];
}

// may be called from any thread or dispatch_queue
- (void)cancel {
    // we want to make sure this block never gets called again and we release all the vars in it
    self.block = nil;
    [self.connection cancel];
    self.connection = nil;
    if (self.taskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.taskID];
        self.taskID = UIBackgroundTaskInvalid;
    }
}

- (void)dealloc {
    [self cancel];
}

#pragma mark - NSURLConnection Delegate Methods - these are only called on the main thread

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data.length = 0;
    _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self __callBlockAndCancelWithData:_data response:_response error:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self __callBlockAndCancelWithData:nil response:nil error:error];
}

@end

#pragma mark -  __NSURLConnection_MFBlockize_OnDealloc 

@implementation __NSURLConnection_MFBlockize_OnDealloc
@synthesize performOnDeallocBlock = __performOnDeallocBlock;

+ (id)performOnDealloc:(void (^)())block {
    __NSURLConnection_MFBlockize_OnDealloc *o = [[__NSURLConnection_MFBlockize_OnDealloc alloc] init];
    o.performOnDeallocBlock = block;
    return o;
}

- (void)dealloc {
    // it's possible that the block could become nil between the if and the call so get a local copy
    void (^performOnDeallocBlock)() = self.performOnDeallocBlock;
    if (performOnDeallocBlock) {
        performOnDeallocBlock();
    }
}

@end