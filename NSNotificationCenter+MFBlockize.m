//
//  NSNotificationCenter+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 7/18/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "NSNotificationCenter+MFBlockize.h"

#import <objc/runtime.h>

@interface __NSNotificationCenter_MFBlockize_Helper : NSObject
@property (nonatomic, retain) id realObserver;
@end

@implementation NSNotificationCenter (MFBlockize)

+ (void)mfAddObserver:(id)observer name:(NSString *)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(id observer, NSNotification *n))block {
    __NSNotificationCenter_MFBlockize_Helper *helper = [[[__NSNotificationCenter_MFBlockize_Helper alloc] init] autorelease];
    __block id weakObserver = observer;
    helper.realObserver = [[NSNotificationCenter defaultCenter] addObserverForName:name object:obj queue:queue usingBlock:^(NSNotification *n) {
        block(weakObserver, n);
    }];
    objc_setAssociatedObject(observer, name, helper, OBJC_ASSOCIATION_RETAIN);
}

+ (void)mfAddObserver:(id)observer name:(NSString *)name usingBlock:(void (^)(id observer, NSNotification *n))block {
    [self mfAddObserver:observer name:name object:nil queue:nil usingBlock:block];
}

+ (void)mfRemoveObserver:(id)observer name:(NSString *)name {
    objc_setAssociatedObject(observer, name, nil, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation __NSNotificationCenter_MFBlockize_Helper
@synthesize realObserver;

- (void)dealloc {
    // remove real observer!
    if (self.realObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.realObserver];
        self.realObserver = nil;
    }
    [super dealloc];
}

@end