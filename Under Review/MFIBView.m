//
//  MFIBView.m
//  zabbi
//
//  Created by Jason Gregori on 10/5/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFIBView.h"

#import <objc/runtime.h>

@implementation MFIBView

+ (id)mfView {
    static char nibKey;
    UINib *nib = objc_getAssociatedObject(self, &nibKey);
    if (!nib) {
        nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:[NSBundle mainBundle]];
        objc_setAssociatedObject(self, &nibKey, nib, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    NSAssert1([objects count], @"%@: +mfView: We weren't able to load anything from the nib!", NSStringFromClass(self));
    MFIBView *view = [objects objectAtIndex:0];
    NSAssert1([view isKindOfClass:[self class]], @"%@: +mfView: We didn't get an actual view!", NSStringFromClass(self));
    return view;
}

#pragma mark - Override these methods so they're more efficient

- (id)initWithFrame:(CGRect)frame {
    self = [[self class] mfView];
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        self.frame = frame;
    }
    return self;
}

+ (id)new {
    return [self mfView];
}

@end
