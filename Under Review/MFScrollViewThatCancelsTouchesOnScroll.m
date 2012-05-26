//
//  MFScrollViewThatCancelsTouchesOnScroll.m
//  zabbi
//
//  Created by Jason Gregori on 9/21/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFScrollViewThatCancelsTouchesOnScroll.h"

@implementation MFScrollViewThatCancelsTouchesOnScroll

static void __MFScrollViewThatCancelsTouchesOnScroll_sharedInit(MFScrollViewThatCancelsTouchesOnScroll *scrollview) {
    scrollview.canCancelContentTouches = YES;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        __MFScrollViewThatCancelsTouchesOnScroll_sharedInit(self);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        __MFScrollViewThatCancelsTouchesOnScroll_sharedInit(self);
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

@end
