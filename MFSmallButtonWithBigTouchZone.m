//
//  MFSmallButtonWithBigTouchZone.m
//  zabbi
//
//  Created by Jason Gregori on 9/27/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFSmallButtonWithBigTouchZone.h"

@implementation MFSmallButtonWithBigTouchZone

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // if point is within 22 pts of center, hit
    if (CGRectContainsPoint(CGRectInset((CGRect){[self convertPoint:self.center fromView:self.superview], CGSizeZero}, -22, -22), point)) {
        return self;
    }
    return nil;
}

@end
