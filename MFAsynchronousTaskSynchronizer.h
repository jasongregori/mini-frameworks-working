//
//  MFAsynchronousTaskSynchronizer.h
//  zabbi
//
//  Created by Jason Gregori on 1/31/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

// @mf: allows you to run a block after a set of asynchronous tasks have all completed

/*
 
 - A task takes a `finished` block. Once the task is done, a task must call the `finished` block.
 - A task may return an object if it wants. That object is retained until the task is cancelled or finished.

 - If the synchronizer is cancelled, all tasks that are not done are cancelled.
 - If a task is cancelled, you must not call the `finished` block.
 
 - You may not add any more tasks after start tasks is called.
 - The synchronizer is automatically cancelled if it deallocs.
 
 */

#import <Foundation/Foundation.h>

typedef void (^MFAsynchronousTaskSynchronizerFinishedBlock)();

@interface MFAsynchronousTaskSynchronizer : NSObject

- (void)addTask:(id (^)(void (^finished)()))task;
- (void)addTask:(id (^)(void (^finished)()))task
    cancelBlock:(void (^)())cancelBlock;
- (void)setCompletionBlock:(void (^)())completionBlock;
- (void)startTasks;

- (void)cancel;

@end
