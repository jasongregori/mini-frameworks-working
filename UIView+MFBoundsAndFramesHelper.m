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

- (CGSize)mfSizeThatFitsAndIsAtMost:(CGSize)size {
    CGSize newSize = [self sizeThatFits:size];
    newSize.width = MIN(newSize.width, size.width);
    newSize.height = MIN(newSize.height, newSize.height);
    return newSize;
}

@end
