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
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSURLResponse *response;
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
    __NSURLConnection_MFBlockize_Helper *helper = [[[__NSURLConnection_MFBlockize_Helper alloc] initWithRequest:request block:block] autorelease];
    if (!helper) { return nil; }
    // ## the onDealloc object retains the helper in it's block and cancels it and releases it on dealloc
    return [__NSURLConnection_MFBlockize_OnDealloc performOnDealloc:^(void) {
        [helper cancel];
    }];
}

+ (void)mfSendWithOwner:(id)owner request:(NSURLRequest *)request withBlock:(void (^)(id weakOwner, NSData *data, NSURLResponse *response, NSError *error))block {
    __block id weakOwner = owner;
    __block NSURLRequest *weakRequest = request;
    id object = [self mfSendRequest:request withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
        // call block
        if (block) { block(weakOwner, data, response, error); }
        // remove association
        objc_setAssociatedObject(weakOwner, weakRequest, nil, OBJC_ASSOCIATION_RETAIN);
    }];
    // associate object with owner
    objc_setAssociatedObject(owner, request, object, OBJC_ASSOCIATION_RETAIN);
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
            [self release];
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
    
    [super dealloc];
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
    __NSURLConnection_MFBlockize_OnDealloc *o = [[[__NSURLConnection_MFBlockize_OnDealloc alloc] init] autorelease];
    o.performOnDeallocBlock = block;
    return o;
}

- (void)dealloc {
    if (self.performOnDeallocBlock) {
        self.performOnDeallocBlock();
    }
    self.performOnDeallocBlock = nil;
    
    [super dealloc];
}

@end