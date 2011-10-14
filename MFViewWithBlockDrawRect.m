//
//  MFViewWithBlockDrawRect.m
//  zabbi
//
//  Created by Jason Gregori on 9/14/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFViewWithBlockDrawRect.h"

@implementation MFViewWithBlockDrawRect
@synthesize drawRectBlock;

- (void)drawRect:(CGRect)rect
{
    if (self.drawRectBlock) {
        self.drawRectBlock(rect);
    }
}

@end
