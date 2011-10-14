//
//  UIControl+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 8/3/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "UIControl+MFBlockize.h"

#import <objc/runtime.h>

@interface __UIControl_MFBlockize_Helper : NSObject
@property (nonatomic, copy) void (^block)(id sender, UIEvent *event);
- (void)callBlockWith:(id)sender event:(UIEvent *)event;
@end

@implementation UIControl (MFBlockize)
- (void)mfAddForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id sender, UIEvent *event))block {
    __UIControl_MFBlockize_Helper *helper = [[[__UIControl_MFBlockize_Helper alloc] init] autorelease];
    helper.block = block;
    [self addTarget:helper action:@selector(callBlockWith:event:) forControlEvents:controlEvents];
    objc_setAssociatedObject(self, (__bridge void *)helper, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)mfOnTap:(void (^)(id sender, UIEvent *event))block {
    [self mfAddForControlEvents:UIControlEventTouchUpInside block:block];
}
@end

@implementation __UIControl_MFBlockize_Helper
@synthesize block;

- (void)callBlockWith:(id)sender event:(UIEvent *)event {
    if (block) {
        block(sender, event);
    }
}

- (void)dealloc {
    self.block = nil;
    [super dealloc];
}

@end