//
//  NSURLConnection+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 7/22/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: Allows you to send use NSURLConnection with blocks

/*
 
 You have two options for making requests:
 
 • mfSend...
    • Retain the object returned. If you release it, the connection is cancelled.
 • mfSendWithOwner...
    • The connection is kept alive until the owner is dealloced or the connection finishes.
 
 Notes
 -----
 
 • Your block will be run on the main thread.
 • background - if you set this to YES, we will keep the app running in the background to send this request.
 
 • NSURLConnection+MFBlockize is completely thread and dispatch_queue safe. It uses the main thread to run the url connection.
 • Once your block is called; the block, the connection, and all the data needed for it is released.
   You do not need to worry about releasing the object, at that point it is basically an nsobject that is retaining nothing.
 
 */

#import <Foundation/Foundation.h>

@interface NSURLConnection (MFBlockize)

+ (id)mfSendRequest:(NSURLRequest *)request background:(BOOL)background withBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block;

// Defaults: background = NO
+ (id)mfSendRequestForURL:(NSString *)url withBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block;

/*
 • The connection becomes associated with the owner.
 • This type of request is handy when you know you will only be cancelling if you yourself are dealloced.
 • weakOwner is given back to the block as a convience for you
 • NB: Make sure you don't create a retain cycle here in your blocks!
*/
+ (void)mfSendWithOwner:(id)owner request:(NSURLRequest *)request background:(BOOL)background withBlock:(void (^)(id weakOwner, NSData *data, NSURLResponse *response, NSError *error))block;

#pragma mark images
+ (id)mfGetImage:(NSString *)url withBlock:(void (^)(UIImage *image, NSError *error))block;

// The block set with this method is called for every image downloaded. In it, you may cache images.
+ (void)mfSetImageCacheBlock:(void (^)(NSString *url, UIImage *image))block;
// The block set in this method is called when an image is requested, return it here to avoid redownloading it.
+ (void)mfSetImageFromCacheBlock:(UIImage *(^)(NSString *url))block;

@end
