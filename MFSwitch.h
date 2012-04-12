//
//  MFSwitch.h
//  zabbi
//
//  Created by Jason Gregori on 4/12/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

// @mf: A switch statement for objects

/*
 
 - objects are compared using -isEqual:
 - if case objects are arrays or sets, we'll double check if the object is in it using -doesContain:
 
 - cases is a nil terminated list of objects and blocks
 - the blocks take no arguments
 - the list must alternate between object and block until the last item
 - at the end of the list you may put a default block (without an object before it)

 example:
 
    __block NSUInteger value;
    [MFSwitch switch:@"asdf"
     cases:@"test", ^{
         value = 2;
     }, @"asdf", ^{
         value = 5;
     }, [NSSet setWithObjects:@"ety", @"hrtynh", @"as", nil], ^{
         value = 9;
     }, ^{
         // default block
         value = 100;
     }
     nil];
 
 */

#import <Foundation/Foundation.h>

@interface MFSwitch : NSObject

+ (void)switch:(id)object cases:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
// the blocks passed into here must return an object
+ (id)returnSwitch:(id)object cases:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end