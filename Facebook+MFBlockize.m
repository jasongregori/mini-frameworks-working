//
//  Facebook+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 7/21/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "Facebook+MFBlockize.h"

#import <objc/runtime.h>

@interface __Facebook_MFBlockize_Helper : NSObject <FBRequestDelegate>
// this is used to make sure our call object is not dealloced before we're done with it
@property (nonatomic, retain) FBRequest *request;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, copy) void (^successBlock)(NSInteger statusCode, id result);
@property (nonatomic, copy) void (^failBlock)(NSInteger statusCode, NSError *error);
@end

@implementation Facebook (MFBlockize)

- (id)mfRequestWithGraphPath:(NSString *)graphPath
                   andParams:(NSDictionary *)params
                       owner:(id)owner
                successBlock:(void (^)(id weakOwner, NSInteger statusCode, id result))successBlock
                   failBlock:(void (^)(id weakOwner, NSInteger statusCode, NSError *error))failBlock {
    return [self mfRequestWithGraphPath:graphPath andParams:params andHTTPMethod:@"GET" owner:owner successBlock:successBlock failBlock:failBlock];
}

- (id)mfRequestWithGraphPath:(NSString *)graphPath
                   andParams:(NSDictionary *)params
               andHTTPMethod:(NSString *)httpMethod
                       owner:(id)owner
                successBlock:(void (^)(id weakOwner, NSInteger statusCode, id result))successBlock
                   failBlock:(void (^)(id weakOwner, NSInteger statusCode, NSError *error))failBlock {
    
    __Facebook_MFBlockize_Helper *helper = [[[__Facebook_MFBlockize_Helper alloc] init] autorelease];
    
    FBRequest *request = [self requestWithGraphPath:graphPath andParams:[[params mutableCopy] autorelease] andHttpMethod:httpMethod andDelegate:helper];
    // make sure request stays alive as long as we need it
    helper.request = request;
    // make sure helper stays alive as long as we need it
    objc_setAssociatedObject(owner, request, helper, OBJC_ASSOCIATION_RETAIN);

    __block id weakOwner = owner;
    helper.successBlock = ^(NSInteger statusCode, id result) {
        successBlock(weakOwner, statusCode, result);
        [self mfCancelCallWithOwner:weakOwner object:request];
    };
    helper.failBlock = ^(NSInteger statusCode, NSError *error) {
        failBlock(weakOwner, statusCode, error);
        [self mfCancelCallWithOwner:weakOwner object:request];
    };

    return request;
}



- (void)mfCancelCallWithOwner:(id)owner object:(id)cancelObject {
    objc_setAssociatedObject(owner, cancelObject, nil, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation __Facebook_MFBlockize_Helper
@synthesize request, successBlock, failBlock, statusCode;

- (void)dealloc {
    self.request.delegate = nil;
    self.request = nil;
    self.successBlock = nil;
    self.failBlock = nil;
    
    [super dealloc];
}

#pragma mark -

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        self.statusCode = [(NSHTTPURLResponse *)response statusCode];
    }
    else {
        self.statusCode = 0;
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    if (self.successBlock) {
        self.successBlock(self.statusCode, result);
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    if (self.failBlock) {
        self.failBlock(self.statusCode, error);
    }
}

@end