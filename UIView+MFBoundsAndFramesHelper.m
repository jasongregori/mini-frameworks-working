//
//  UIView+MFBoundsAndFramesHelper.m
//  zabbi
//
//  Created by Jason Gregori on 10/7/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "UIView+MFBoundsAndFramesHelper.h"

@implementation UIView (MFBoundsAndFramesHelper)

- (CGFloat)mfFrameHeight {
    return self.frame.size.height;
}
- (void)setMfFrameHeight:(CGFloat)mfFrameHeight {
    CGRect frame = self.frame;
    frame.size.height = mfFrameHeight;
    self.frame = frame;
}

// only positive numbers will be used, put a negative number to ignore that part
- (void)mfUpdateFrame:(CGRect)updateFrame {
    CGRect frame = self.frame;
    if (updateFrame.origin.x >= 0) {
        frame.origin.x = updateFrame.origin.x;
    }
    if (updateFrame.origin.y >= 0) {
        frame.origin.y = updateFrame.origin.y;
    }
    if (updateFrame.size.width >= 0) {
        frame.size.width = updateFrame.size.width;
    }
    if (updateFrame.size.height >= 0) {
        frame.size.height = updateFrame.size.height;
    }
    self.frame = frame;
}

- (CGSize)mfSizeThatFitsAndIsAtMost:(CGSize)size {
    CGSize newSize = [self sizeThatFits:size];
    newSize.width = MIN(newSize.width, size.width);
    newSize.height = MIN(newSize.height, newSize.height);
    return newSize;
}

@end
