//
//  NSCollection+MFHighOrder.h
//  zabbi
//
//  Created by Jason Gregori on 9/26/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MFHighOrder)

// mapper can return nil to not add the object to the array
- (NSArray *)mfMap:(id (^)(id obj))mapper;

@end
