//
//  UIActionSheet+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 8/18/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (MFBlockize)

+ (id)mfAnotherWithTitle:(NSString *)title
otherButtonTitlesAndBlocks:(NSString *)firstTitle, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)mfAnotherWithTitle:(NSString *)title
       cancelButtonTitle:(NSString *)cancelTitle
                   block:(void (^)())cancelBlock
otherButtonTitlesAndBlocks:(NSString *)firstTitle, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)mfAnotherWithTitle:(NSString *)title
       cancelButtonTitle:(NSString *)cancelTitle
                   block:(void (^)())cancelBlock
  destructiveButtonTitle:(NSString *)destructiveTitle
                   block:(void (^)())destructiveBlock
otherButtonTitlesAndBlocks:(NSString *)firstTitle, ... NS_REQUIRES_NIL_TERMINATION;

- (NSUInteger)mfAddButtonWithTitle:(NSString *)title block:(void (^)())block;
- (NSUInteger)mfAddDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block;
// the cancel button should be added last to look correctly
- (NSUInteger)mfAddCancelButtonWithTitle:(NSString *)title block:(void (^)())block;

@end
