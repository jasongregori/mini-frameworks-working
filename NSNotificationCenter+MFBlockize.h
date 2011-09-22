//
//  NSNotificationCenter+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 7/18/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @MF: Observe notifications without having to worry about cleaning up after.

/*
 
 When you add an observance using one of these methods, it is linked to the observer.
 You do not have to worry about removing the observance later.
 The observance will automatically be removed when the observer is dealloced.
 Adding an observance with these methods will not retain the observer and is passed to your block so you do not have to create a weak version.
 NB: you may only observe a specific notification name once, adding another replaces the first.
 
 */

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (MFBlockize)
+ (void)mfAddObserver:(id)observer name:(NSString *)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(id weakObserver, NSNotification *n))block;
// uses nil for object and queue
+ (void)mfAddObserver:(id)observer name:(NSString *)name usingBlock:(void (^)(id weakObserver, NSNotification *n))block;

+ (void)mfRemoveObserver:(id)observer name:(NSString *)name;
@end
