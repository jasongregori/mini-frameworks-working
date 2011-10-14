//
//  NSURLConnection+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 7/22/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "NSURLConnection+MFBlockize.h"

#import <objc/runtime.h>

@interface __NSURLConnection_MFBlockize_Helper : NSObject
@property (nonatomic, copy) void (^block)(NSData *data, NSURLResponse *response, NSError *error);
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
- (id)initWithRequest:(NSURLRequest *)request block:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block;
- (void)cancel;
@end

@interface __NSURLConnection_MFBlockize_OnDealloc : NSObject
@property (nonatomic, copy) void (^performOnDeallocBlock)();
+ (id)performOnDealloc:(void (^)())block;
@end

@implementation NSURLConnection (MFBlockize)

+ (id)mfSendRequestForURL:(NSString *)url withBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    return [self mfSendRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] withBlock:block];
}

+ (id)mfSendRequest:(NSURLRequest *)request withBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    // ## the helper will run the request and call the block
    __NSURLConnection_MFBlockize_Helper *helper = [[__NSURLConnection_MFBlockize_Helper alloc] initWithRequest:request block:block];
    if (!helper) { return nil; }
    // ## the onDealloc object retains the helper in it's block and cancels it and releases it on dealloc
    return [__NSURLConnection_MFBlockize_OnDealloc performOnDealloc:^(void) {
        [helper cancel];
    }];
}

+ (void)mfSendWithOwner:(id)owner request:(NSURLRequest *)request withBlock:(void (^)(id weakOwner, NSData *data, NSURLResponse *response, NSError *error))block {
    __unsafe_unretained id weakOwner = owner;

    // ## use the object itself as the key because we know it will be around and unique for it's lifetime
    __block id object = nil;
    object = [self mfSendRequest:request withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
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

@implementation __NSURLConnection_MFBlockize_Helper
@synthesize block = ___block, data = __data, connection = __connection, response = __response;

- (id)initWithRequest:(NSURLRequest *)request block:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    if ((self = [super init])) {
        self.data = [NSMutableData data];
        self.block = block;
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];

        if (!self.connection) {
            if (block) {
                block(nil,nil,[NSError errorWithDomain:@"NSURLConnection+MFBlockize" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Failed to start connection" forKey:NSLocalizedDescriptionKey]]);
            }
            return nil;
        }
    }
    return self;
}

- (void)cancel {
    [self.connection cancel];
    self.connection = nil;
    self.block = nil;
    self.data = nil;
}

- (void)dealloc {
    [self cancel];
    
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.data.length = 0;
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.block) {
        self.block(self.data, self.response, nil);
    }
    [self cancel];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.block) {
        self.block(nil,nil,error);
    }
    [self cancel];
}

@end

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