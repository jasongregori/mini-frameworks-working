//
//  UIBarButtonItem+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 7/28/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "UIBarButtonItem+MFBlockize.h"

#import <objc/runtime.h>

@interface __UIBarButtonItem_MFBlockize_Helper : NSObject
@property (nonatomic, copy) void (^block)();
- (void)callBlock;
@end

@implementation UIBarButtonItem (MFBlockize)

+ (id)mfAnotherWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem targetBlock:(void (^)())block {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:nil action:NULL];
    item.mfTargetBlock = block;
    return item;
}

+ (id)mfAnotherWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style targetBlock:(void (^)())block {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:style target:nil action:NULL];
    item.mfTargetBlock = block;
    return item;
}

+ (id)mfAnotherWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style targetBlock:(void (^)())block {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title style:style target:nil action:NULL];
    item.mfTargetBlock = block;
    return item;
}

static char __associatedHelperKey;

- (void)setMfTargetBlock:(void (^)())mfTargetBlock {
    __UIBarButtonItem_MFBlockize_Helper *helper = [[__UIBarButtonItem_MFBlockize_Helper alloc] init];
    helper.block = mfTargetBlock;
    self.target = helper;
    self.action = @selector(callBlock);
    objc_setAssociatedObject(self, &__associatedHelperKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)())mfTargetBlock {
    return [objc_getAssociatedObject(self, &__associatedHelperKey) block];
}

@end

@implementation __UIBarButtonItem_MFBlockize_Helper
@synthesize block;


- (void)callBlock {
    if (self.block) {
        self.block();
    }
}

@end