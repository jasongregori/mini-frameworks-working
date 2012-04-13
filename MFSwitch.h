//
//  MFSwitch.h
//  zabbi
//
//  Created by Jason Gregori on 4/12/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

// @mf: A switch statement for objects

/*
 
 The switch is a simple method that takes an switch-object and a nil terminated list.
 The list contains alternating pairs of a case-object and a return-object.
 If the switch-object matches a case-object, return-object is returned.
 If the list ends with a dangling single object it is assumed to be the "default" return-object and is returned if there are no matches.
 nil is returned if there are no matches.
 
 - compare-objects are compared using -isEqual:
 - if a compare-object is an array or set, we'll double check if the object is in it using -doesContain:

 
 
 

 examples:
 
    __block NSUInteger value;
    [MFSwitch blockSwitch:@"asdf"
                    cases:@"test", ^{
                        value = 2;
                    }, @"234", ^{
                        value = 5;
                    }, [NSSet setWithObjects:@"asdf", @"hrtynh", @"as", nil], ^{
                        value = 9;
                    }, ^{
                        // default block
                        value = 100;
                    }, nil];
    
    UIView *view = [MFSwitch blockReturnSwitch:@"button"
                                         cases:@"green", ^{
                                             UIView *v = [UIView new];
                                             v.backgroundColor = [UIColor greenColor];
                                             return v;
                                         }, @"button", ^{
                                             return [UIButton buttonWithType:UIButtonTypeCustom];
                                         }, ^{
                                             // default
                                             return [UIView new];
                                         }, nil];
 
 */

#import <Foundation/Foundation.h>

@interface MFSwitch : NSObject

// you may pass any types of objects for return-objects, the matching one is returned
+ (id)objectSwitch:(id)object cases:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

// return-objects must be blocks that take no arguments and return nothing
// runs the matching block
+ (void)blockSwitch:(id)object cases:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

// return-objects must be blocks that take no arguments and return id
// the matching block will be run and the return object returned
+ (id)blockReturnSwitch:(id)object cases:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end