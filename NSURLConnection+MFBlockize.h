//
//  NSURLConnection+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 7/22/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: Allows you to send use NSURLConnection with blocks

/*
 
 You have two options for making requests
 
 • mfSend...
    • Retain the object returned. If you release it, the connection is cancelled.
 • mfSendWithOwner...
    • The connection is kept alive until the owner is dealloced or the connection finishes.
    • The connection becomes associated with the owner.
    • This type of request is handy when you know you will only be cancelling if you yourself are dealloced.
    • weakOwner is given back to the block as a convience for you
    • NB: Make sure you don't create a retain cycle here in your blocks!
 
 */

// !!!: You may only send a request from an NSThread right now. In the future, we should have our own internal thread like these guys: https://github.com/gowalla/AFNetworking/blob/master/AFNetworking/AFHTTPRequestOperation.m

#import <Foundation/Foundation.h>

@interface NSURLConnection (MFBlockize)

+ (id)mfSendRequestForURL:(NSString *)url withBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block;
+ (id)mfSendRequest:(NSURLRequest *)request withBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block;
+ (void)mfSendWithOwner:(id)owner request:(NSURLRequest *)request withBlock:(void (^)(id weakOwner, NSData *data, NSURLResponse *response, NSError *error))block;

#pragma mark images
+ (id)mfGetImage:(NSString *)url withBlock:(void (^)(UIImage *image, NSError *error))block;

@end
