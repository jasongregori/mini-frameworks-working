//
//  MFEasyInit.h
//  zabbi
//
//  Created by Jason Gregori on 7/18/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: A collection of categories with one call methods for alloc init autoreleasing things.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (MFEasyInit)
// alloc init autoreleases another instance of your object
+ (id)mfAnother;
@end

@interface UIActivityIndicatorView (MFEasyInit)
+ (id)mfAnotherWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;
+ (id)mfAnotherWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style animating:(BOOL)animating;
@end

@interface UIAlertView (MFEasyInit)
// an alert with an OK button
+ (id)mfAnotherWithTitle:(NSString *)title message:(NSString *)message;
+ (id)mfAnotherWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
@end

@interface UIBarButtonItem (MFEasyInit)
+ (id)mfAnotherWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action;
+ (id)mfAnotherWithCustomView:(UIView *)customView;
+ (id)mfAnotherWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
+ (id)mfAnotherWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
@end

@interface UINavigationController (MFEasyInit)
+ (id)mfAnotherWithRootViewController:(UIViewController *)rootViewController;
@end

@interface UIView (MFEasyInit)
+ (id)mfAnotherWithFrame:(CGRect)frame;
@end