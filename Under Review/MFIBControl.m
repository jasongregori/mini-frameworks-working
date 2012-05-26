//
//  MFIBControl.m
//  zabbi
//
//  Created by Jason Gregori on 11/7/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "MFIBControl.h"

#import <objc/runtime.h>

@implementation MFIBControl

+ (id)mfControl {
    static char nibKey;
    UINib *nib = objc_getAssociatedObject(self, &nibKey);
    if (!nib) {
        nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:[NSBundle mainBundle]];
        objc_setAssociatedObject(self, &nibKey, nib, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    NSAssert1([objects count], @"%@: +mfView: We weren't able to load anything from the nib!", NSStringFromClass(self));
    MFIBControl *control = [objects objectAtIndex:0];
    NSAssert1([control isKindOfClass:[self class]], @"%@: +mfControl: We didn't get an actual control!", NSStringFromClass(self));
    return control;
}

#pragma mark - Override these methods so they're more efficient

- (id)initWithFrame:(CGRect)frame {
    self = [[self class] mfControl];
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        self.frame = frame;
    }
    return self;
}

+ (id)new {
    return [self mfControl];
}

@end
