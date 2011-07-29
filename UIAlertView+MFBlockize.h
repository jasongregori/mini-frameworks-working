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
 
 */

#import <UIKit/UIKit.h>

@interface UIAlertView (MFBlockize)

+ (id)mfAnotherWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle block:(void (^)())cancelBlock otherButtonTitlesAndBlocks:(NSString *)firstTitle, ... NS_REQUIRES_NIL_TERMINATION;

- (NSUInteger)mfAddButtonWithTitle:(NSString *)title block:(void (^)())block;

@end
