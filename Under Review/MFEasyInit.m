//
//  MFEasyInit.m
//  zabbi
//
//  Created by Jason Gregori on 7/18/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFEasyInit.h"

#import <objc/runtime.h>

static char __MFEasyInit__CustomizationBlockKey;

@implementation NSObject (MFEasyInit)
+ (void)__mfCustomize:(id)object {
    void (^block)(id object) = objc_getAssociatedObject([self class], &__MFEasyInit__CustomizationBlockKey);
    if (block) {
        block(object);
    }
}
+ (id)mfAnother {
    id object = [[self alloc] init];
    [[self class] __mfCustomize:object];
    return object;
}
+ (void)mfSetCustomizationBlock:(void (^)(id object))customizationBlock {
    objc_setAssociatedObject(self, &__MFEasyInit__CustomizationBlockKey, [customizationBlock copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation UIActivityIndicatorView (MFEasyInit)
+ (id)mfAnotherWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style {
    return [[self alloc] initWithActivityIndicatorStyle:style];
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

// OK is "OK" in most langauges, for the few that aren't I've provided the unicode.
static NSString *ok() {
    static NSString *ok = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *okDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"\u0645\u0648\u0627\u0641\u0642", @"ar", // @"موافق"
                                      @"\u05D0\u05D9\u05E9\u05D5\u05E8", @"he", // @"אישור"
                                      @"Oke", @"id",
                                      @"\uC2B9\uC778", @"ko", // @"승인"
                                      @"\u0E15\u0E01\u0E25\u0E07", @"th", // @"ตกลง"
                                      @"Tamam", @"tr",
                                      @"\u597D", @"zh_CN", // @"好"
                                      @"\u597D", @"zh_TW", // @"好"
                                      nil];
        // get the current locale
        NSString *key = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        // only translate to this language if the dev has
        if (![[[NSBundle mainBundle] localizations] containsObject:key]) {
            // if not, use the dev localization
            key = [[NSBundle mainBundle] developmentLocalization];
        }
        ok = [okDictionary valueForKey:key];
        if (!ok) {
            // must not be a special case, use plain old "OK"
            ok = @"OK";
        }
        
        // save it forever
    });
    return ok;
}

+ (id)mfAnotherWithTitle:(NSString *)title message:(NSString *)message {
    return [self mfAnotherWithTitle:title message:message delegate:nil cancelButtonTitle:ok() otherButtonTitles:nil];
}
+ (id)mfAnotherWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    UIAlertView *alert = [[self alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
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
+ (id)mfAnotherWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action {
    return [[self alloc] initWithBarButtonSystemItem:systemItem target:target action:action];
}
+ (id)mfAnotherWithCustomView:(UIView *)customView {
    return [[self alloc] initWithCustomView:customView];
}
+ (id)mfAnotherWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    return [[self alloc] initWithImage:image style:style target:target action:action];
}
+ (id)mfAnotherWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    return [[self alloc] initWithTitle:title style:style target:target action:action];
}
@end

@implementation UIImageView (MFEasyInit)
+ (id)mfAnotherWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}
@end

@implementation UINavigationController (MFEasyInit)
+ (id)mfAnotherWithRootViewController:(UIViewController *)rootViewController {
    id c = [[self alloc] initWithRootViewController:rootViewController];
    [UINavigationController __mfCustomize:c];
    return c;
}
@end

@implementation UIView (MFEasyInit)
+ (id)mfAnotherWithFrame:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}
+ (id)mfAnotherWithNib {
    static char nibKey;
    UINib *nib = objc_getAssociatedObject(self, &nibKey);
    if (!nib) {
        nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:[NSBundle mainBundle]];
        objc_setAssociatedObject(self, &nibKey, nib, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSAssert2(nib, @"%@: +mfAnotherWithNib: No nib found for this class: %@!", NSStringFromClass(self), NSStringFromClass(self));
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    NSAssert1([objects count], @"%@: +mfAnotherWithNib: We weren't able to load anything from the nib!", NSStringFromClass(self));
    id view = [objects objectAtIndex:0];
    NSAssert1([view isKindOfClass:[self class]], @"%@: +mfAnotherWithNib: We didn't get an actual view!", NSStringFromClass(self));
    return view;
}
@end