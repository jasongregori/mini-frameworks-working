//
//  UIAlertView+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 7/29/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: lets you use blocks with UIAlertViews

/*
 
 • For otherButtonTitlesAndBlocks alternate between titles and blocks
 • You may pass nil for a block if you dont need a call back for that button
 • You must end the list with a nil in a title slot!
 • You may not end on a nil block since we don't know if there might be another title and block
 
 • NB: Adding blocks to your alertView sets it's delegate, resetting it's delegate will make your blocks not get called.
 • NB: Your blocks will be retained as long as the alert exists
       so if you are retaining the alert you'll want to use a weak ref to yourself
       and if you are not retaining the alert you probably want a strong ref so you won't be dealloced before the alert is finished
 
 */

#import <UIKit/UIKit.h>

@interface UIAlertView (MFBlockize)

+ (id)mfAnotherWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle block:(void (^)())cancelBlock otherButtonTitlesAndBlocks:(NSString *)firstTitle, ... NS_REQUIRES_NIL_TERMINATION;

- (NSUInteger)mfAddButtonWithTitle:(NSString *)title block:(void (^)())block;

@end
