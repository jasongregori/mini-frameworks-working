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
- (void)addBlock:(void (^)())block forButtonIndex:(NSUInteger)index;
@end

@implementation UIAlertView (MFBlockize)

+ (id)mfAnotherWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle block:(void (^)())cancelBlock otherButtonTitlesAndBlocks:(NSString *)firstTitle, ... {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
    va_list titlesAndBlocks;
    va_start(titlesAndBlocks, firstTitle);
    
    NSString *buttonTitle = firstTitle;
    while (buttonTitle) {
        void (^buttonBlock)() = va_arg(titlesAndBlocks, void (^)());
        [alert mfAddButtonWithTitle:buttonTitle block:buttonBlock];
        buttonTitle = va_arg(titlesAndBlocks, NSString *);
    }
    
    if (cancelTitle) {
        alert.cancelButtonIndex = [alert mfAddButtonWithTitle:cancelTitle block:cancelBlock];
    }
    
    return alert;
}

- (NSUInteger)mfAddButtonWithTitle:(NSString *)title block:(void (^)())block {
    static char associationKey;
    __UIAlertView_MFBlockize_Helper *helper = objc_getAssociatedObject(self, &associationKey);
    if (!helper) {
        helper = [[[__UIAlertView_MFBlockize_Helper alloc] init] autorelease];
        self.delegate = helper;
        objc_setAssociatedObject(self, &associationKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSUInteger index = [self addButtonWithTitle:title];
    [helper addBlock:block forButtonIndex:index];
    return index;
}

@end

@interface __UIAlertView_MFBlockize_Helper ()
@property (nonatomic, retain) NSMutableDictionary *indexToBlock;
@end

@implementation __UIAlertView_MFBlockize_Helper
@synthesize indexToBlock;

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
