//
//  NSCollection+MFBoundsSafe.h
//  zabbi
//
//  Created by Jason Gregori on 12/7/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

// @mf: array methods that are bounds safe. returns nil if out of bounds.

@interface NSArray (MFBoundsSafe)
- (id)mfSafeObjectAtIndex:(NSUInteger)index;
- (NSArray *)mfSafeSubarrayWithRange:(NSRange)range;
@end
