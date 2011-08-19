//
//  Facebook+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 7/21/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: allows you to do cool facebook stuff with blocks

/*
 
 • The object returned by the method may be used to cancel the fb call.
 • You may ignore the returned object if you will not need the option to cancel.
 • The blocks are retained until the fb call is finished, the fb call is cancelled, or the owner is dealloced.
 • An object is added to the owner as an associated object.
 
 */

#import <Foundation/Foundation.h>

#import "Facebook.h"

@interface Facebook (MFBlockize)

+ (id <FBSessionDelegate>)mfGlobalSessionDelegate;

#pragma mark Login
// you cannot cancel this
- (void)mfAuthorize:(NSArray *)permissions
       successBlock:(void (^)())successBlock
          failBlock:(void (^)(BOOL userDidCancel))failBlock;

#pragma mark Request
- (id)mfRequestWithGraphPath:(NSString *)graphPath
                   andParams:(NSDictionary *)params
                       owner:(id)owner
                successBlock:(void (^)(id weakOwner, NSInteger statusCode, id result))successBlock
                   failBlock:(void (^)(id weakOwner, NSInteger statusCode, NSError *error))failBlock;
- (id)mfRequestWithGraphPath:(NSString *)graphPath
                   andParams:(NSDictionary *)params
               andHTTPMethod:(NSString *)httpMethod
                       owner:(id)owner
                successBlock:(void (^)(id weakOwner, NSInteger statusCode, id result))successBlock
                   failBlock:(void (^)(id weakOwner, NSInteger statusCode, NSError *error))failBlock;

- (void)mfCancelCallWithOwner:(id)owner object:(id)cancelObject;

@end
