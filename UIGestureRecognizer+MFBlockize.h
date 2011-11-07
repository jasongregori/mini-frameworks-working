//
//  UIGestureRecognizer+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 11/7/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

// @mf: allows you to use blocks with gesture recognizers instead of targets and actions

/*
 
 Once a block is added it may not be removed.
 The block is released when the gestureRecognizer is deallocated.
 
 */

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (MFBlockize)

+ (id)mfAnotherWithTargetBlock:(void (^)(id gestureRecognizer))block;
- (void)mfAddTargetBlock:(void (^)(id gestureRecognizer))block;

// only gets called when the gesture recognizer is in the state recognized
+ (id)mfAnotherWithTargetBlockOnRecognized:(void (^)())block;
- (void)mfAddTargetBlockOnRecognized:(void (^)())block;

@end
