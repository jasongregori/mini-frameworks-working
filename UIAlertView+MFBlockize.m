//
//  UIAlertView+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 7/29/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "UIAlertView+MFBlockize.h"

#import <objc/runtime.h>

@interface __UIAlertView_MFBlockize_Helper : NSObject <UIAlertViewDelegate>
+ (__UIAlertView_MFBlockize_Helper *)helperForAlertView:(UIAlertView *)alert;
- (void)addBlock:(void (^)())block forButtonIndex:(NSUInteger)index;
@end

@implementation UIAlertView (MFBlockize)

+ (id)mfAnotherWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle block:(void (^)())cancelBlock otherButtonTitlesAndBlocks:(NSString *)firstTitle, ... {

    // you must set the cancel button in here otherwise it doesn't always go the right place
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:nil] autorelease];

    __UIAlertView_MFBlockize_Helper *helper = [__UIAlertView_MFBlockize_Helper helperForAlertView:alert];
    
    if (cancelTitle) {
        [helper addBlock:cancelBlock forButtonIndex:alert.cancelButtonIndex];
    }
    
    va_list titlesAndBlocks;
    va_start(titlesAndBlocks, firstTitle);
    NSString *buttonTitle = firstTitle;
    while (buttonTitle) {
        void (^buttonBlock)() = va_arg(titlesAndBlocks, void (^)());
        [helper addBlock:buttonBlock forButtonIndex:[alert addButtonWithTitle:buttonTitle]];
        
        buttonTitle = va_arg(titlesAndBlocks, NSString *);
    }
    va_end(titlesAndBlocks);
    
    return alert;
}

- (NSUInteger)mfAddButtonWithTitle:(NSString *)title block:(void (^)())block {
    NSUInteger index = [self addButtonWithTitle:title];
    [[__UIAlertView_MFBlockize_Helper helperForAlertView:self] addBlock:block forButtonIndex:index];
    return index;
}

@end

@interface __UIAlertView_MFBlockize_Helper ()
@property (nonatomic, retain) NSMutableDictionary *indexToBlock;
@end

@implementation __UIAlertView_MFBlockize_Helper
@synthesize indexToBlock;

+ (__UIAlertView_MFBlockize_Helper *)helperForAlertView:(UIAlertView *)alert {
    static char associationKey;
    __UIAlertView_MFBlockize_Helper *helper = objc_getAssociatedObject(alert, &associationKey);
    if (!helper) {
        helper = [[[__UIAlertView_MFBlockize_Helper alloc] init] autorelease];
        alert.delegate = helper;
        objc_setAssociatedObject(alert, &associationKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return helper;
}

- (id)init {
    self = [super init];
    if (self) {
        self.indexToBlock = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.indexToBlock = nil;
    [super dealloc];
}

- (void)addBlock:(void (^)())block forButtonIndex:(NSUInteger)index {
    if (block) {
        [self.indexToBlock setObject:[[block copy] autorelease]
                              forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    void (^block)() = [self.indexToBlock objectForKey:[NSNumber numberWithUnsignedInteger:buttonIndex]];
    if (block) {
        block();
    }
}

@end
