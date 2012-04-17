//
//  Facebook+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 7/21/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: allows you to do cool facebook stuff with blocks

#import <Foundation/Foundation.h>

#import "Facebook.h"

@interface Facebook (MFBlockize)

#pragma mark Login
/*
    - once you use these methods you may not change the sessionDelegate of the facebook object
    - you cannot cancel this
 */
- (void)mfAuthorize:(NSArray *)permissions
       successBlock:(void (^)())successBlock
          failBlock:(void (^)(BOOL userDidCancel))failBlock;
- (void)mfSetDidLogoutBlock:(void (^)())block;
- (void)mfSetDidExtendTokenBlock:(void (^)(NSString *accessToken, NSDate *expiresAt))block;
- (void)mfSetSessionInvalidatedBlock:(void (^)())block;

#pragma mark Dialog

// never actually tested!
// remember they don't actually tell us if it was successful or not
- (void)mfDialog:(NSString *)action
       andParams:(NSMutableDictionary *)params
    successBlock:(void (^)(NSURL *url))successBlock;

#pragma mark Request
// retain the object returned, the request is cancelled on dealloc
- (id)mfRequestWithGraphPath:(NSString *)graphPath
                   andParams:(NSDictionary *)params
               andHTTPMethod:(NSString *)httpMethod
                successBlock:(void (^)(NSInteger statusCode, id result))successBlock
                   failBlock:(void (^)(NSInteger statusCode, NSString *error))failBlock;
/*
 
 • The object returned by the method may be used to cancel the fb call.
 • You may ignore the returned object if you will not need the option to cancel.
 • The blocks are retained until the fb call is finished, the fb call is cancelled, or the owner is dealloced.
 • An object is added to the owner as an associated object.
 
 */
- (id)mfRequestWithGraphPath:(NSString *)graphPath
                   andParams:(NSDictionary *)params
                       owner:(id)owner
                successBlock:(void (^)(id weakOwner, NSInteger statusCode, id result))successBlock
                   failBlock:(void (^)(id weakOwner, NSInteger statusCode, NSString *error))failBlock;
- (id)mfRequestWithGraphPath:(NSString *)graphPath
                   andParams:(NSDictionary *)params
               andHTTPMethod:(NSString *)httpMethod
                       owner:(id)owner
                successBlock:(void (^)(id weakOwner, NSInteger statusCode, id result))successBlock
                   failBlock:(void (^)(id weakOwner, NSInteger statusCode, NSString *error))failBlock;

- (void)mfCancelCallWithOwner:(id)owner object:(id)cancelObject;

@end
