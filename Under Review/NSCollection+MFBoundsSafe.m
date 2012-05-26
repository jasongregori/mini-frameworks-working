//
//  NSCollection+MFBoundsSafe.m
//  zabbi
//
//  Created by Jason Gregori on 12/7/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "NSCollection+MFBoundsSafe.h"

@implementation NSArray (MFBoundsSafe)

- (id)mfSafeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    return nil;
}

- (NSArray *)mfSafeSubarrayWithRange:(NSRange)range {
    if (NSMaxRange(range) > self.count) {
        if (range.location > self.count) {
            return nil;
        }
        range.length = self.count - range.location;
    }
    return [self subarrayWithRange:range];
}

@end
