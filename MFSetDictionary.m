//
//  MFSetDictionary.m
//  zabbi
//
//  Created by Jason Gregori on 1/10/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFSetDictionary.h"

@interface MFSetDictionary () {
    NSMutableDictionary *_dictionary;
}
@end

@implementation MFSetDictionary

- (id)init {
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addObject:(id)object forKey:(id)key {
    NSMutableSet *set = [_dictionary objectForKey:key];
    if (!set) {
        set = [NSMutableSet set];
        [_dictionary setObject:set forKey:key];
    }
    [set addObject:object];
}

- (void)removeObject:(id)object forKey:(id)key {
    NSMutableSet *set = [_dictionary objectForKey:key];
    if (set) {
        [set removeObject:object];
        if (![set count]) {
            [_dictionary removeObjectForKey:key];
        }
    }
}

- (NSSet *)allObjectsForKey:(id)key {
    return [_dictionary objectForKey:key];
}

- (NSUInteger)countForKey:(id)key {
    return [[_dictionary objectForKey:key] count];
}

- (void)removeAllObjectsForKey:(id)key {
    [_dictionary removeObjectForKey:key];
}

- (void)enumerateObjectsForKey:(id)key usingBlock:(void (^)(id obj, BOOL *stop))block {
    [(NSSet *)[_dictionary objectForKey:key] enumerateObjectsUsingBlock:block];
}

@end
