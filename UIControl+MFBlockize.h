//
//  UIControl+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 8/3/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: blocks for UIControl

#import <UIKit/UIKit.h>

/*
 
 NB: do not create retain cycles!
 
 */

@interface UIControl (MFBlockize)
- (void)mfAddForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id sender, UIEvent *event))block;
@end
