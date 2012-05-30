//
//  MFBackgroundTask.h
//  zabbi
//
//  Created by Jason Gregori on 2/14/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

// @mf: A simpler method for running a task in the background

#import <Foundation/Foundation.h>

/*
 
 When you start a task, it is automatically finished if time runs out.
 It returns a finish block, call it to finish your task.
 
 */

@interface MFBackgroundTask : NSObject

+ (void (^)(void))startBackgroundTaskAndReturnFinishBlock;

@end
