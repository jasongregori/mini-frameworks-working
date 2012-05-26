//
//  UIGestureRecognizer+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 11/7/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "UIGestureRecognizer+MFBlockize.h"

#import <objc/runtime.h>

@interface __UIGestureRecognizer_MFBlockize_Helper : NSObject
@property (nonatomic, copy) void (^block)(id gestureRecognizer);
- (void)action:(UIGestureRecognizer *)gestureRecognizer;
@end

@implementation UIGestureRecognizer (MFBlockize)

+ (id)mfAnotherWithTargetBlock:(void (^)(id gestureRecognizer))block {
    UIGestureRecognizer *r = [self new];
    [r mfAddTargetBlock:block];
    return r;
}
- (void)mfAddTargetBlock:(void (^)(id gestureRecognizer))block {
    __UIGestureRecognizer_MFBlockize_Helper *helper = [__UIGestureRecognizer_MFBlockize_Helper new];
    helper.block = block;
    objc_setAssociatedObject(self, (__bridge void *)helper, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addTarget:helper action:@selector(action:)];
}

+ (id)mfAnotherWithTargetBlockOnRecognized:(void (^)())block {
    UIGestureRecognizer *r = [self new];
    [r mfAddTargetBlockOnRecognized:block];
    return r;    
}
- (void)mfAddTargetBlockOnRecognized:(void (^)())block {
    [self mfAddTargetBlock:^(UIGestureRecognizer *gestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
            block();
        }
    }];
}

@end

@implementation __UIGestureRecognizer_MFBlockize_Helper
@synthesize block;

- (void)action:(UIGestureRecognizer *)gestureRecognizer {
    if (self.block) {
        self.block(gestureRecognizer);
    }
}

@end
