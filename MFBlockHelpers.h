//
//  MFBlockHelpers.h
//  zabbi
//
//  Created by Jason Gregori on 8/12/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: a group of little helpers that use blocks 
// NB: blocks are called on the main dispatch queue


#import <Foundation/Foundation.h>

// calls your block on dealloc
@interface MFDeallocBlockHelper : NSObject
+ (id)deallocBlockHelper:(void (^)())block;
- (void)cancel;
@end

// calls your block after the desired time UNLESS dealloced
// NB: do not call cancel from inside your block as this may result in a deadlock
@interface MFTimerBlockHelper : NSObject
+ (id)timerBlockHelperAfter:(NSTimeInterval)seconds call:(void (^)())block;
- (id)initAfter:(NSTimeInterval)seconds call:(void (^)())block;
- (void)cancel;
@end