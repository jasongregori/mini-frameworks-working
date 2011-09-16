//
//  MFTimeSince.h
//  zabbi
//
//  Created by Jason Gregori on 9/15/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: Gives you the time since a date as a string

/*
 
 Time is measured in different units. An hour is a unit with 60*60 seconds in it.
 All localization are passed the number of units as an int (%i).
 If no localization is found that fits a time, the highest localization will be used.
 
 */

#import <Foundation/Foundation.h>

@interface MFTimeSince : NSObject

// Use these for the global MFTimeSince
+ (void)setLocalizationString:(NSString *)localization forUpToThisManyUnits:(double)upto secondsInUnit:(NSUInteger)secondsInUnit;
+ (NSString *)timeSince:(NSDate *)date;
+ (NSString *)timeSinceTimestamp:(NSTimeInterval)timestamp;

// You may use these if you need more than one MFTimeSince instance
- (void)setLocalizationString:(NSString *)localization forUpToThisManyUnits:(double)upto secondsInUnit:(NSUInteger)secondsInUnit;
- (NSString *)timeSince:(NSDate *)date;
- (NSString *)timeSinceTimestamp:(NSTimeInterval)timestamp;

@end
