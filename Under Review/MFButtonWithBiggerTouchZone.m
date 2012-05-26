//
//  MFSmallButtonWithBigTouchZone.m
//  zabbi
//
//  Created by Jason Gregori on 9/27/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFButtonWithBiggerTouchZone.h"

@implementation MFButtonWithBiggerTouchZone

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hidden || !self.userInteractionEnabled || self.alpha < 0.01) {
        return nil;
    }
    
    // if point is within 22 pts of center, hit
    CGRect minimumTouchBounds = CGRectInset((CGRect){[self convertPoint:self.center fromView:self.superview], CGSizeZero}, -22, -22);
    CGRect unionBounds = CGRectUnion(self.bounds, minimumTouchBounds);
    if (CGRectContainsPoint(unionBounds, point)) {
        return self;
    }
    return nil;
}

@end
