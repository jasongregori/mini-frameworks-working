//
//  MFBlockHelpers.m
//  zabbi
//
//  Created by Jason Gregori on 8/12/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFBlockHelpers.h"

@interface MFDeallocBlockHelper ()
@property (copy) void (^__dblock)();
@end

@implementation MFDeallocBlockHelper
@synthesize __dblock;

+ (id)deallocBlockHelper:(void (^)())block {
    MFDeallocBlockHelper *helper = [[[self alloc] init] autorelease];
    helper.__dblock = block;
    return helper;
}

- (void)dealloc {
    if (self.__dblock) {
        dispatch_sync(dispatch_get_main_queue(), ^ { self.__dblock(); });
        self.__dblock = nil;
    }
    [super dealloc];
}

- (void)cancel {
    self.__dblock = nil;
}

@end

@interface MFTimerBlockHelper ()
@property (copy) void (^__tblock)();
@property dispatch_source_t __timer;
@end

@implementation MFTimerBlockHelper
@synthesize __tblock, __timer;

+ (id)timerBlockHelperAfter:(NSTimeInterval)seconds call:(void (^)())block {
    return [[[self alloc] initAfter:seconds call:block] autorelease];
}

- (id)initAfter:(NSTimeInterval)seconds call:(void (^)())block {
    self = [super init];
    if (self) {
        __block MFTimerBlockHelper *weakSelf = self;
        self.__tblock = block;
        self.__timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                              0,
                                              0,
                                              dispatch_get_main_queue());
        dispatch_source_set_timer(self.__timer,
                                  dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC),
                                  DISPATCH_TIME_FOREVER,
                                  0);
        dispatch_source_set_event_handler(self.__timer, ^(void) {
            if (weakSelf.__tblock) {
                weakSelf.__tblock();
                weakSelf.__tblock = nil;
            }
            dispatch_source_cancel(weakSelf.__timer);
        });
        dispatch_resume(self.__timer);
    }
    return self;
}

- (void)dealloc {    
    self.__tblock = nil;
    [self cancel];
    dispatch_release(self.__timer);

    [super dealloc];
}

- (void)cancel {
    dispatch_source_cancel(self.__timer);    
}

@end