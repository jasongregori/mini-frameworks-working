//
//  MFTouchDownGestureRecognizer.m
//  zabbi
//
//  Created by Jason Gregori on 11/7/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "MFTouchDownGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation MFTouchDownGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        // don't prevent anything!
        self.cancelsTouchesInView = NO;
        self.delaysTouchesBegan = NO;
        self.delaysTouchesEnded = NO;
    }
    return self;
}

// any touch means we're done!
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateRecognized;
}

// don't prevent anything!
- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return NO;
}
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
    return NO;
}

@end
