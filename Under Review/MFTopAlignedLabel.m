//
//  MFTopAlignedLabel.m
//  zabbi
//
//  Created by Jason Gregori on 12/2/11.
//  Copyright 2011 zabbi, Inc. All rights reserved.
//

#import "MFTopAlignedLabel.h"

@implementation MFTopAlignedLabel

- (void)drawTextInRect:(CGRect)rect {
    rect.size.height = [self.text sizeWithFont:self.font constrainedToSize:rect.size lineBreakMode:self.lineBreakMode].height;
    if (self.numberOfLines != 0) {
        rect.size.height = MIN(rect.size.height, self.numberOfLines * self.font.lineHeight);
    }
    [super drawTextInRect:rect];
}

@end
