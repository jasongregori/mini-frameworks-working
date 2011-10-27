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
+ (id)performOnDealloc:(void (^)())block;
@end

@implementation NSURLConnection (MFBlockize)

+ (id)mfSendRequestForURL:(NSString *)url withBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    return [self mfSendRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] background:NO withBlock:block];
}

+ (id)mfSendRequest:(NSURLRequest *)request background:(BOOL)background withBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    // ## the helper will run the request and call the block
    __NSURLConnection_MFBlockize_Helper *helper = [[__NSURLConnection_MFBlockize_Helper alloc] initWithRequest:request background:background block:block];
    if (!helper) { return nil; }
    // ## the onDealloc object retains the helper in it's block and cancels it and releases it on dealloc
    return [__NSURLConnection_MFBlockize_OnDealloc performOnDealloc:^(void) {
        [helper cancel];
    }];
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
    void (^_block)(NSData *data, NSURLResponse *response, NSError *error);
    NSMutableData *_data;
    NSURLConnection *_connection;
    NSURLResponse *_response;
    UIBackgroundTaskIdentifier _taskID;
}
@end

@implementation __NSURLConnection_MFBlockize_Helper

- (id)initWithRequest:(NSURLRequest *)request background:(BOOL)background block:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    if ((self = [super init])) {
        _data = [NSMutableData data];
        _block = [block copy];
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        if (!_connection) {
            if (block) {
                block(nil,nil,[NSError errorWithDomain:@"NSURLConnection+MFBlockize" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Failed to start connection" forKey:NSLocalizedDescriptionKey]]);
            }
            return nil;
        }
        
        UIApplication *app = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier taskID = UIBackgroundTaskInvalid;
        if (background) {
            taskID = [app beginBackgroundTaskWithExpirationHandler:^{
                [app endBackgroundTask:taskID];
            }];
        }
        _taskID = taskID;
    }
    return self;
}

- (void)cancel {
    [_connection cancel];
    _connection = nil;
    _block = nil;
    _data = nil;
    if (_taskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_taskID];
        _taskID = UIBackgroundTaskInvalid;
    }
}

- (void)dealloc {
    [self cancel];
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data.length = 0;
    _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_block) {
        _block(_data, _response, nil);
    }
    [self cancel];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_block) {
        _block(nil,nil,error);
    }
    [self cancel];
}

@end

#pragma mark -  __NSURLConnection_MFBlockize_OnDealloc 
   
@interface __NSURLConnection_MFBlockize_OnDealloc () {
    void (^_performOnDeallocBlock)();
}
@end

@implementation __NSURLConnection_MFBlockize_OnDealloc

+ (id)performOnDealloc:(void (^)())block {
    __NSURLConnection_MFBlockize_OnDealloc *o = [[__NSURLConnection_MFBlockize_OnDealloc alloc] init];
    o->_performOnDeallocBlock = block;
    return o;
}

- (void)dealloc {
    if (_performOnDeallocBlock) {
        _performOnDeallocBlock();
    }
}

@end