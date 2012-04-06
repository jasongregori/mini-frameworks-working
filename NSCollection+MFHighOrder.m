//
//  NSCollection+MFHighOrder.m
//  zabbi
//
//  Created by Jason Gregori on 9/26/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "NSCollection+MFHighOrder.h"

@implementation NSArray (MFHighOrder)

- (NSMutableArray *)mfFilteredArrayWithTest:(BOOL (^)(id obj))test {
    return [self mfMap:^id(id obj) {
        return test(obj) ? obj : nil;
    }];
}

- (id)mfFold:(id)initialValue function:(void (^)(id initialValue, id obj))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(initialValue, obj);
    }];
    return initialValue;
}

- (NSMutableArray *)mfMap:(id (^)(id obj))mapper {
    return [self mfFold:[NSMutableArray array] function:^(id initialValue, id obj) {
        id o = mapper(obj);
        if (o) {
            [initialValue addObject:o];
        }
    }];
}

@end


@implementation NSMutableArray (MFHighOrder)

- (void)mfFilterWithTest:(BOOL (^)(id obj))test {
    [self filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return test(evaluatedObject);
    }]];
}

- (id)mfPopObjectPassingTest:(BOOL (^)(id obj))test {
    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return test(obj);
    }];
    if (index != NSNotFound) {
        id obj = [self objectAtIndex:index];
        [self removeObjectAtIndex:index];
        return obj;
    }
    return nil;
}

- (id)mfPopObjectUsingPredicate:(NSPredicate *)predicate {
    return [self mfPopObjectPassingTest:^BOOL(id obj) {
        return [predicate evaluateWithObject:obj];
    }];
}

@end


@implementation NSDictionary (MFHighOrder)

- (NSMutableDictionary *)mfDictionaryByRemovingKeysExcept:(id)firstObject, ... {
    NSMutableSet *args = [NSMutableSet set]; va_list vl; va_start(vl, firstObject); id o = firstObject; while (o) { [args addObject:o]; o = va_arg(vl, id); } va_end(vl);
    return [self mfFilteredDictionaryWithTest:^BOOL(id key, id object) {
        return [args containsObject:key];
    }];
}

- (NSMutableDictionary *)mfFilteredDictionaryWithTest:(BOOL (^)(id key, id object))test {
    return [self mfMap:^id(id key, id object) {
        return test(key, object) ? object : nil;
    }];
}

- (id)mfFold:(id)initialValue function:(void (^)(id initialValue, id key, id object))block {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(initialValue, key, obj);
    }];
    return initialValue;
}

- (NSMutableDictionary *)mfMap:(id (^)(id key, id object))mapper {
    return [self mfFold:[NSMutableDictionary dictionary] function:^(id initialValue, id key, id object) {
        id o = mapper(key, object);
        if (o) {
            [initialValue setObject:o forKey:key];
        }
    }];
}

@end


@implementation NSMutableDictionary (MFHighOrder)

- (void)mfFilterWithTest:(BOOL (^)(id key, id object))test {
    [[self copy] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!test(key, obj)) {
            [self removeObjectForKey:key];
        }
    }];
}

- (id)mfPopObjectForKey:(id)key {
    id obj = [self objectForKey:key];
    [self removeObjectForKey:key];
    return obj;
}

@end