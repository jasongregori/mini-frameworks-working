//
//  MFEasyInit.m
//  zabbi
//
//  Created by Jason Gregori on 7/18/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFEasyInit.h"

@implementation NSObject (MFEasyInit)
+ (id)mfAnother {
    return [[[self alloc] init] autorelease];
}
@end

@implementation UIActivityIndicatorView (MFEasyInit)
+ (id)mfAnotherWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style {
    return [[[self alloc] initWithActivityIndicatorStyle:style] autorelease];
}
+ (id)mfAnotherWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style animating:(BOOL)animating {
    UIActivityIndicatorView *aiv = [self mfAnotherWithActivityIndicatorStyle:style];
    if (animating) {
        [aiv startAnimating];
    }
    return aiv;
}
@end

@implementation UIAlertView (MFEasyInit)
+ (id)mfAnotherWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    UIAlertView *alert = [[[self alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] autorelease];
    // ## we must add the other button titles here since we cannot pass the varargs into the init method
    va_list buttons;
    va_start(buttons, otherButtonTitles);
    NSString *name = otherButtonTitles;
    while (name) {
        [alert addButtonWithTitle:name];
        name = va_arg(buttons, NSString *);
    }
    va_end(buttons);
    return alert;
}
@end

@implementation UIBarButtonItem (MFEasyInit)
+ (id)mfAnotherWithSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action {
    return [[[self alloc] initWithBarButtonSystemItem:systemItem target:target action:action] autorelease];
}
+ (id)mfAnotherWithCustomView:(UIView *)customView {
    return [[[self alloc] initWithCustomView:customView] autorelease];
}
+ (id)mfAnotherWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    return [[[self alloc] initWithImage:image style:style target:target action:action] autorelease];
}
+ (id)mfAnotherWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    return [[[self alloc] initWithTitle:title style:style target:target action:action] autorelease];
}
@end

@implementation UINavigationController (MFEasyInit)
+ (id)mfAnotherWithRootViewController:(UIViewController *)rootViewController {
    return [[[self alloc] initWithRootViewController:rootViewController] autorelease];
}
@end

@implementation UIView (MFEasyInit)
+ (id)mfAnotherWithFrame:(CGRect)frame {
    return [[[self alloc] initWithFrame:frame] autorelease];
}
@end