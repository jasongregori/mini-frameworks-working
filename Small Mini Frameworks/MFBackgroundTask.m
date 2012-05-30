//
//  MFBackgroundTask.m
//  zabbi
//
//  Created by Jason Gregori on 2/14/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFBackgroundTask.h"

@implementation MFBackgroundTask

+ (void (^)(void))startBackgroundTaskAndReturnFinishBlock {
    UIApplication *app = [UIApplication sharedApplication];
    // the task id
    __block UIBackgroundTaskIdentifier taskID = UIBackgroundTaskInvalid;
    // finish block
    void (^finishBlock)() = ^{
        if (taskID != UIBackgroundTaskInvalid) {
            [app endBackgroundTask:taskID];
            taskID = UIBackgroundTaskInvalid;
        }
    };
    taskID = [app beginBackgroundTaskWithExpirationHandler:finishBlock];
    return finishBlock;
}

@end
