//
//  MFTimeSince.m
//  zabbi
//
//  Created by Jason Gregori on 9/15/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFTimeSince.h"

NSString * const MFTimeSinceLocalizationOneSecondKey = @"OneSecond";
NSString * const MFTimeSinceLocalizationUpToSixtySecondsKey = @"MoreSeconds";
NSString * const MFTimeSinceLocalizationOneMinuteKey = @"OneMinute";
NSString * const MFTimeSinceLocalizationUpToSixtyMinutesKey = @"MoreSeconds";
NSString * const MFTimeSinceLocalizationOneHourKey = @"OneHour";
NSString * const MFTimeSinceLocalizationUpToTwentyFourHoursKey = @"MoreHours";
NSString * const MFTimeSinceLocalizationOneDayKey = @"OneDay";
NSString * const MFTimeSinceLocalizationMoreThanOneDayKey = @"MoreDays";

@interface __MFTimeSince_Localization : NSObject
@property (nonatomic, copy) NSString *localization;
@property (nonatomic, assign) NSTimeInterval upto;
@property (nonatomic, assign) NSTimeInterval secondsInUnit;
@end

@interface MFTimeSince ()
@property (nonatomic, strong) NSMutableArray *__localizations;
@end

@implementation MFTimeSince
@synthesize __localizations;

static MFTimeSince *__globalTimeSince = nil;
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __globalTimeSince = [[MFTimeSince alloc] init];
    });
}

+ (void)setLocalizationString:(NSString *)localization forUpToThisManyUnits:(double)upto secondsInUnit:(NSUInteger)secondsInUnit {
    [__globalTimeSince setLocalizationString:localization forUpToThisManyUnits:upto secondsInUnit:secondsInUnit];
}

+ (NSString *)timeSince:(NSDate *)date {
    return [__globalTimeSince timeSince:date];
}

+ (NSString *)timeSinceTimestamp:(NSTimeInterval)timestamp {
    return [__globalTimeSince timeSinceTimestamp:timestamp];
}

- (id)init {
    self = [super init];
    if (self) {
        self.__localizations = [NSMutableArray array];
    }
    return self;
}


- (void)setLocalizationString:(NSString *)localization forUpToThisManyUnits:(double)upto secondsInUnit:(NSUInteger)secondsInUnit {
    __MFTimeSince_Localization *l = [[__MFTimeSince_Localization alloc] init];
    l.localization = localization;
    l.upto = upto * (double)secondsInUnit;
    l.secondsInUnit = secondsInUnit;
    
    [self.__localizations addObject:l];
    
    [self.__localizations sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 upto] < [obj2 upto]) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
}

- (NSString *)timeSince:(NSDate *)date {
    return date ? [self timeSinceTimestamp:[date timeIntervalSince1970]] : nil;
}

- (NSString *)timeSinceTimestamp:(NSTimeInterval)timestamp {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - timestamp;
    if (interval < 0) {
        interval = 1;
    }
    
    for (__MFTimeSince_Localization *l in self.__localizations) {
        if (interval < l.upto) {
            return [NSString stringWithFormat:l.localization, (int)(interval/l.secondsInUnit)];
        }
    }
    
    // if it didn't match use the last one
    __MFTimeSince_Localization *l = [self.__localizations lastObject];
    NSAssert(l, @"MFTimeSince: You have not set and localization strings!");
    return [NSString stringWithFormat:l.localization, (int)(interval/l.secondsInUnit)];
}

@end


@implementation __MFTimeSince_Localization
@synthesize localization, upto, secondsInUnit;

- (NSString *)description {
    return [NSString stringWithFormat:@"Upto %f seconds, \"%@\"", self.upto, self.localization];
}


@end