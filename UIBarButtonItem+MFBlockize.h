//
//  UIBarButtonItem+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 7/28/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (MFBlockize)

+ (id)mfAnotherWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem targetBlock:(void (^)())block;
+ (id)mfAnotherWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style targetBlock:(void (^)())block;
+ (id)mfAnotherWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style targetBlock:(void (^)())block;

@property (nonatomic, copy) void (^mfTargetBlock)();

@end
