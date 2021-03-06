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
        // onDealloc will retain the helper until the next call.
        // we want onDealloc to release the helper so it won't keep a bunch of unused junk around.
        // some users will release onDealloc inside the block call, so we should not reference it after the block is called.
        weakOnDealloc.performOnDeallocBlock = nil;

        // call block
        if (block) { block(data, response, error); }
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

+ (id)mfSendWithOwner:(id)owner request:(NSURLRequest *)request background:(BOOL)background withBlock:(void (^)(id weakOwner, NSData *data, NSURLResponse *response, NSError *error))block {
    __unsafe_unretained id weakOwner = owner;
    
    // ## use the object itself as the key because we know it will be around and unique for it's lifetime
    __block __unsafe_unretained id object = nil;
    object = [self mfSendRequest:request background:background withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
        // call block
        if (block) { block(weakOwner, data, response, error); }
        // remove association
        if (weakOwner) {
            objc_setAssociatedObject(weakOwner, (__bridge void *)object, nil, OBJC_ASSOCIATION_RETAIN);
        }
    }];
    // associate object with owner
    if (owner) {
        objc_setAssociatedObject(owner, (__bridge void *)object, object, OBJC_ASSOCIATION_RETAIN);
    }
    
    return object;
}

#pragma mark - images

static void (^__imageCacheBlock)(NSString *url, UIImage *image);
static UIImage *(^__imageFromCacheBlock)(NSString *url);

+ (id)mfGetImageWithOwner:(id)owner url:(NSString *)url withBlock:(void (^)(UIImage *image, NSError *error))block {
    NSString *immutableURL = [url copy];
    // check cache
    if (__imageFromCacheBlock) {
        UIImage *image = __imageFromCacheBlock(url);
        if (image) {
            block(image, nil);
            return nil;
        }
    }
    return [self mfSendWithOwner:owner
                         request:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                      background:NO
                       withBlock:^(id weakOwner, NSData *data, NSURLResponse *response, NSError *error) {
                           if (block) {
                               if (data) {
                                   UIImage *image = [UIImage imageWithData:data];
                                   // cache image
                                   if (__imageCacheBlock) {
                                       __imageCacheBlock(immutableURL, image);
                                   }
                                   block(image, nil);
                               }
                               else {
                                   block(nil, error);
                               }
                           }
                       }];
}

+ (id)mfGetImage:(NSString *)url withBlock:(void (^)(UIImage *image, NSError *error))block {
    return [self mfGetImageWithOwner:nil url:url withBlock:block];
}

+ (void)mfSetImageCacheBlock:(void (^)(NSString *url, UIImage *image))block {
    __imageCacheBlock = [block copy];
}
+ (void)mfSetImageFromCacheBlock:(UIImage *(^)(NSString *url))block {
    __imageFromCacheBlock = [block copy];
}

@end

#pragma mark - __NSURLConnection_MFBlockize_Helper

@interface __NSURLConnection_MFBlockize_Helper () {
    // always accessed from main thread except on init and dealloc
    void (^___block)(NSData *data, NSURLResponse *response, NSError *error);
    NSMutableData *__data;
    NSURLResponse *__response;
}
// potentially accessed from multiple threads (atomic)
@property (strong) NSURLConnection *connection;
@property UIBackgroundTaskIdentifier taskID;

// may only be called on main thread
- (void)__startConnection:(NSURLRequest *)request;
- (void)__callBlockAndCleanupWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error;
- (void)__nilBlock;
- (void)__cleanup;
@end

@implementation __NSURLConnection_MFBlockize_Helper
@synthesize connection = __connection, taskID = __taskID;

- (id)initWithRequest:(NSURLRequest *)request background:(BOOL)background block:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    if ((self = [super init])) {
        __data = [NSMutableData data];
        ___block = block;
        
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

// may be called from any thread or dispatch_queue
- (void)cancel {
    // we want to make sure this block never gets called again and we release all the vars in it
    // wait for the main thread, this insures that our block will not be called on the main thread after this call because we only ever call it from the main thread
    [self performSelectorOnMainThread:@selector(__nilBlock) withObject:nil waitUntilDone:YES];

    // stop the connection
    if (self.connection) {
        [self.connection cancel];
        self.connection = nil;
    }
    
    // cleanup
    [self __cleanup];
}

- (void)dealloc {
    // the connection retains us, so if we get here the connection must have finished or cancelled already
    [self __cleanup];
}

// may only be called on main thread
- (void)__startConnection:(NSURLRequest *)request {
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
    
    if (!self.connection) {
        [self __callBlockAndCleanupWithData:nil response:nil error:[NSError errorWithDomain:@"NSURLConnection+MFBlockize" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Failed to start connection" forKey:NSLocalizedDescriptionKey]]];
    }
}

// may only be called on main thread
- (void)__callBlockAndCleanupWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    if (___block) {
        ___block(data, response, error);
        // release the block, it should never be called more than once
        ___block = nil;
    }
    [self __cleanup];
}

- (void)__nilBlock {
    ___block = nil;
}

// may be called from any thread or dispatch_queue
- (void)__cleanup {
    if (self.taskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.taskID];
        self.taskID = UIBackgroundTaskInvalid;
    }
}

#pragma mark - NSURLConnection Delegate Methods - these are only called on the main thread

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    __data.length = 0;
    __response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [__data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self __callBlockAndCleanupWithData:__data response:__response error:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self __callBlockAndCleanupWithData:nil response:nil error:error];
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
    if (self.performOnDeallocBlock) {
        self.performOnDeallocBlock();
    }
}

@end