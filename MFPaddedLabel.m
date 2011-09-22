//
//  MFPaddedLabel.m
//  zabbi
//
//  Created by Jason Gregori on 9/21/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFPaddedLabel.h"

@implementation MFPaddedLabel
@synthesize mfPadding = __mfPadding;

static void __MFPaddedLabel_sharedInit(MFPaddedLabel *label) {
    label.mfPadding = UIEdgeInsetsMake(0, 3, 0, 3);
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        __MFPaddedLabel_sharedInit(self);
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        __MFPaddedLabel_sharedInit(self);
    }
    return self;
}

- (void)setMfPadding:(UIEdgeInsets)padding {
    __mfPadding = padding;
    [self setNeedsDisplay];
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.mfPadding)];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    // give super the bounds minus our border
    CGRect adjustedBounds = bounds;
    adjustedBounds.size.width -= self.mfPadding.left + self.mfPadding.right;
    adjustedBounds.size.height -= self.mfPadding.top + self.mfPadding.bottom;
    CGRect newBounds = [super textRectForBounds:adjustedBounds
                         limitedToNumberOfLines:numberOfLines];
    // add the border back into the result
    newBounds.size.width += self.mfPadding.left + self.mfPadding.right;
    newBounds.size.height += self.mfPadding.top + self.mfPadding.bottom;
    return newBounds;
}

@end
