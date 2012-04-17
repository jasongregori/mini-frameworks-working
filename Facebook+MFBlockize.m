//
//  Facebook+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 7/21/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "Facebook+MFBlockize.h"

#import <objc/runtime.h>

@interface __Facebook_MFBlockize_GlobalSessionDelegate : NSObject <FBSessionDelegate>
+ (__Facebook_MFBlockize_GlobalSessionDelegate *)sessionDelegateFor:(Facebook *)facebook;
@property (nonatomic, copy) void (^didLogoutBlock)();
@property (nonatomic, copy) void (^didExtendTokenBlock)(NSString *accessToken, NSDate *expiresAt);
- (void)authorize:(Facebook *)facebook
      permissions:(NSArray *)permissions
     successBlock:(void (^)())successBlock
        failBlock:(void (^)(BOOL userDidCancel))failBlock;
@end

@interface __Facebook_MFBlockize_Dialog_Helper : NSObject <FBDialogDelegate>
@property (nonatomic, copy) void (^successBlock)(NSURL *url);
@end

@interface __Facebook_MFBlockize_Helper : NSObject <FBRequestDelegate>
// this is used to make sure our request object is not dealloced before we're done with it
@property (nonatomic, strong) FBRequest *request;
@property (nonatomic, copy) void (^successBlock)(NSInteger statusCode, id result);
@property (nonatomic, copy) void (^failBlock)(NSInteger statusCode, NSString *error);
@end

@implementation Facebook (MFBlockize)

#pragma mark - Login

- (void)mfAuthorize:(NSArray *)permissions
       successBlock:(void (^)())successBlock
          failBlock:(void (^)(BOOL userDidCancel))failBlock {
    [[__Facebook_MFBlockize_GlobalSessionDelegate sessionDelegateFor:self] authorize:self
                                                                       permissions:permissions
                                                                      successBlock:successBlock
                                                                         failBlock:failBlock];
}

- (void)mfSetDidLogoutBlock:(void (^)())block {
    [[__Facebook_MFBlockize_GlobalSessionDelegate sessionDelegateFor:self] setDidLogoutBlock:block];
}

- (void)mfSetDidExtendTokenBlock:(void (^)(NSString *accessToken, NSDate *expiresAt))block {
    [[__Facebook_MFBlockize_GlobalSessionDelegate sessionDelegateFor:self] setDidExtendTokenBlock:block];
}

#pragma mark - Dialogs

- (void)mfDialog:(NSString *)action
       andParams:(NSMutableDictionary *)params
    successBlock:(void (^)(NSURL *url))successBlock {
    static char dialogKey;
    __Facebook_MFBlockize_Dialog_Helper *h = [__Facebook_MFBlockize_Dialog_Helper new];
    objc_setAssociatedObject(self, &dialogKey, h, OBJC_ASSOCIATION_RETAIN);
    h.successBlock = ^(NSURL *url){
        if (successBlock) {
            successBlock(url);
        }
        objc_setAssociatedObject(self, &dialogKey, nil, OBJC_ASSOCIATION_RETAIN);
    };
    [self dialog:action andParams:params andDelegate:h];
}

#pragma mark - Requests

- (id)mfRequestWithGraphPath:(NSString *)graphPath
                   andParams:(NSDictionary *)params
               andHTTPMethod:(NSString *)httpMethod
                successBlock:(void (^)(NSInteger statusCode, id result))successBlock
                   failBlock:(void (^)(NSInteger statusCode, NSString *error))failBlock {
    id request = [NSObject new];
    [self mfRequestWithGraphPath:graphPath
                       andParams:params
                   andHTTPMethod:httpMethod
                           owner:request
                    successBlock:^(id weakOwner, NSInteger statusCode, id result) {
                        if (successBlock) { successBlock(statusCode, result); };
                    } failBlock:^(id weakOwner, NSInteger statusCode, NSString *error) {
                        if (failBlock) { failBlock(statusCode, error); };
                    }];
    return request;
}

- (id)mfRequestWithGraphPath:(NSString *)graphPath
                   andParams:(NSDictionary *)params
                       owner:(id)owner
                successBlock:(void (^)(id weakOwner, NSInteger statusCode, id result))successBlock
                   failBlock:(void (^)(id weakOwner, NSInteger statusCode, NSString *error))failBlock {
    return [self mfRequestWithGraphPath:graphPath andParams:params andHTTPMethod:@"GET" owner:owner successBlock:successBlock failBlock:failBlock];
}

- (id)mfRequestWithGraphPath:(NSString *)graphPath
                   andParams:(NSDictionary *)params
               andHTTPMethod:(NSString *)httpMethod
                       owner:(id)owner
                successBlock:(void (^)(id weakOwner, NSInteger statusCode, id result))successBlock
                   failBlock:(void (^)(id weakOwner, NSInteger statusCode, NSString *error))failBlock {
        
    __Facebook_MFBlockize_Helper *helper = [[__Facebook_MFBlockize_Helper alloc] init];
    
    FBRequest *request = [self requestWithGraphPath:graphPath
                                          andParams:(params ? [params mutableCopy] : [NSMutableDictionary dictionary])
                                      andHttpMethod:httpMethod
                                        andDelegate:helper];
    // make sure request stays alive as long as we need it
    helper.request = request;
    // make sure helper stays alive as long as we need it
    objc_setAssociatedObject(owner, (__bridge void *)request, helper, OBJC_ASSOCIATION_RETAIN);

    __unsafe_unretained id weakOwner = owner;
    helper.successBlock = ^(NSInteger statusCode, id result) {
        if (successBlock) { successBlock(weakOwner, statusCode, result); }
        [self mfCancelCallWithOwner:weakOwner object:request];
    };
    helper.failBlock = ^(NSInteger statusCode, NSString *error) {
        if (failBlock) { failBlock(weakOwner, statusCode, error); }
        [self mfCancelCallWithOwner:weakOwner object:request];
    };

    return request;
}

- (void)mfCancelCallWithOwner:(id)owner object:(id)cancelObject {
    objc_setAssociatedObject(owner, (__bridge void *)cancelObject, nil, OBJC_ASSOCIATION_RETAIN);
}

@end

#pragma mark - Helpers

@interface __Facebook_MFBlockize_GlobalSessionDelegate ()
@property (nonatomic, copy) void (^successBlock)();
@property (nonatomic, copy) void (^failBlock)(BOOL userDidCancel);
@end

@implementation __Facebook_MFBlockize_GlobalSessionDelegate
@synthesize successBlock = __successBlock, failBlock = __failBlock;
@synthesize didLogoutBlock, didExtendTokenBlock;

+ (__Facebook_MFBlockize_GlobalSessionDelegate *)sessionDelegateFor:(Facebook *)facebook {
    static char associationKey;
    __Facebook_MFBlockize_GlobalSessionDelegate *helper = objc_getAssociatedObject(facebook, &associationKey);
    if (!helper) {
        helper = [[__Facebook_MFBlockize_GlobalSessionDelegate alloc] init];
        objc_setAssociatedObject(facebook, &associationKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return helper;
}

- (id)init {
    self = [super init];
    if (self) {
        // if the app starts up and we were in the middle of a login
        // and the user did not use the login or cancel buttons but just switched back to us
        // we need to cancel!
        __unsafe_unretained __Facebook_MFBlockize_GlobalSessionDelegate *weakself = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *n) {
                                                          [weakself fbDidNotLogin:YES];
                                                      }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)authorize:(Facebook *)facebook
      permissions:(NSArray *)permissions
     successBlock:(void (^)())successBlock
        failBlock:(void (^)(BOOL userDidCancel))failBlock {
    
    self.successBlock = successBlock;
    self.failBlock = failBlock;
    
    facebook.sessionDelegate = self;
    [facebook authorize:permissions];
}

- (void)fbDidLogin {
    if (self.successBlock)
    {
        self.successBlock();
    }
    self.successBlock = nil;
    self.failBlock = nil;
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    if (self.failBlock) {
        self.failBlock(cancelled);
    }
    self.successBlock = nil;
    self.failBlock = nil;
}

- (void)fbDidLogout {
    if (self.didLogoutBlock) {
        self.didLogoutBlock();
    }
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
    if (self.didExtendTokenBlock) {
        self.didExtendTokenBlock(accessToken, expiresAt);
    }
}

@end

@implementation __Facebook_MFBlockize_Dialog_Helper
@synthesize successBlock;

- (void)dialogCompleteWithUrl:(NSURL *)url {
    if (successBlock) {
        successBlock(url);
    }
}

@end

@interface __Facebook_MFBlockize_Helper ()
@property (nonatomic, assign) NSInteger statusCode;
@property (atomic, assign) UIBackgroundTaskIdentifier __taskID;
@end

@implementation __Facebook_MFBlockize_Helper
@synthesize request, successBlock, failBlock, statusCode;
@synthesize __taskID;

- (id)init {
    self = [super init];
    if (self) {
        UIApplication *app = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier taskID = UIBackgroundTaskInvalid;
        taskID = [app beginBackgroundTaskWithExpirationHandler:^(void) {
            [app endBackgroundTask:taskID];
        }];
        self.__taskID = taskID;
    }
    return self;
}

- (void)dealloc {
    if (self.__taskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.__taskID];
        self.__taskID = UIBackgroundTaskInvalid;
    }
    self.request.delegate = nil;
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
        NSString *errorString;
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            errorString = [error localizedDescription];
        }
        else {
            // probably a facebook error. they have tons, try to find the message
            errorString = [[error userInfo] valueForKeyPath:@"error.message"];
            if (!errorString) {
                errorString = [[error userInfo] valueForKeyPath:@"error_msg"];
            }
            if (!errorString) {
                errorString = [[error userInfo] valueForKeyPath:@"error_reason"];
            }
        }
        self.failBlock(self.statusCode, errorString);
    }
}

@end