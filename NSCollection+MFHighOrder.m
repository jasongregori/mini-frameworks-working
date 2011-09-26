//
//  NSCollection+MFHighOrder.m
//  zabbi
//
//  Created by Jason Gregori on 9/26/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "NSCollection+MFHighOrder.h"

@implementation NSArray (MFHighOrder)

- (NSArray *)mfMap:(id (^)(id obj))mapper {
    NSMutableArray *r = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id o = mapper(obj);
        if (o) {
            [r addObject:o];
        }
    }];
    return r;
}

@end
