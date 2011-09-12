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
// if you call this method on a class, any instances created through the mfAnother method will have this block run on it before returned.
// other MFEasyInit mfAnother... methods that make sense to be customized will be.
// it's like a poor man's iOS 5 appearance proxy :)
+ (void)mfSetCustomizationBlock:(void (^)(id object))customizationBlock;
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

@interface UIImageView (MFEasyInit)
+ (id)mfAnotherWithImage:(UIImage *)image;
@end

@interface UINavigationController (MFEasyInit)
+ (id)mfAnotherWithRootViewController:(UIViewController *)rootViewController;
@end

@interface UIView (MFEasyInit)
+ (id)mfAnotherWithFrame:(CGRect)frame;
// if your view has a corresponding nib with the same name, this method will instantiate one.
+ (id)mfAnotherWithNib;
@end