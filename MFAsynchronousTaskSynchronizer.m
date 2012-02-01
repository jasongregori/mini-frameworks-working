//
//  MFAsynchronousTaskSynchronizer.m
//  zabbi
//
//  Created by Jason Gregori on 1/31/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFAsynchronousTaskSynchronizer.h"

@interface MFAsynchronousTaskSynchronizer () {
    NSMutableSet *_taskIDs;
    NSMutableSet *_completedTaskIDs;
    NSMutableArray *_tasks;
    NSMutableDictionary *_cancelBlocks;
    NSMutableDictionary *_taskReturnedObjects;
    void (^_completionBlock)();
}
- (void)__taskFinished:(NSNumber *)taskID;
@end

@implementation MFAsynchronousTaskSynchronizer

- (id)init {
    self = [super init];
    if (self) {
        _taskIDs = [NSMutableSet set];
        _completedTaskIDs = [NSMutableSet set];
        _tasks = [NSMutableArray array];
        _cancelBlocks = [NSMutableDictionary dictionary];
        _taskReturnedObjects = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    [self cancel];
}

- (void)addTask:(id (^)(void (^finished)()))task {
    [self addTask:task cancelBlock:nil];
}

- (void)addTask:(id (^)(void (^finished)()))task
    cancelBlock:(void (^)())cancelBlock {

    NSNumber *taskID = [NSNumber numberWithUnsignedInteger:[_tasks count]];
    [_taskIDs addObject:taskID];
    [_tasks addObject:[task copy]];

    if (cancelBlock) {
        [_cancelBlocks setObject:[cancelBlock copy]
                          forKey:taskID];
    }
}

- (void)setCompletionBlock:(void (^)())completionBlock {
    _completionBlock = [completionBlock copy];
}

- (void)startTasks {
    __unsafe_unretained MFAsynchronousTaskSynchronizer *weakself = self;
    NSUInteger i, count = [_tasks count];
    for (i = 0; i < count; i++) {
        id (^task)(void (^finished)()) = [_tasks objectAtIndex:i];
        NSNumber *taskID = [NSNumber numberWithUnsignedInteger:i];
        
        // run task
        id taskReturnedObject = task(^{
            [weakself __taskFinished:taskID];
        });
        
        // save returned object
        if (taskReturnedObject) {
            [_taskReturnedObjects setObject:taskReturnedObject
                                     forKey:taskID];
        }
    }
    // remove all tasks
    _tasks = nil;
}

- (void)cancel {
    // remove completion block so it can't be called
    _completionBlock = nil;
    
    for (NSNumber *taskID in [[_taskIDs allObjects] sortedArrayUsingSelector:@selector(compare:)]) {
        // call and remove cancel block
        void (^cancelBlock)() = [_cancelBlocks objectForKey:taskID];
        if (cancelBlock) {
            cancelBlock();
            [_cancelBlocks removeObjectForKey:taskID];
        }
        // remove task returned object
        [_taskReturnedObjects removeObjectForKey:taskID];
    }
}

- (void)__taskFinished:(NSNumber *)taskID {
    [_completedTaskIDs addObject:taskID];
    // remove cancel and returned object
    [_cancelBlocks removeObjectForKey:taskID];
    [_taskReturnedObjects removeObjectForKey:taskID];
    
    // check if all our tasks have completed
    if ([_completedTaskIDs isEqualToSet:_taskIDs]) {
        if (_completionBlock) {
            _completionBlock();
            _completionBlock = nil;
        }
    }
}

@end
