//
//  NSCollection+MFHighOrder.h
//  zabbi
//
//  Created by Jason Gregori on 9/26/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MFHighOrder)

- (NSMutableArray *)mfFilteredArrayWithTest:(BOOL (^)(id obj))test;
- (id)mfFold:(id)initialValue function:(void (^)(id initialValue, id obj))block;
// mapper can return nil to not add the object to the array
- (NSMutableArray *)mfMap:(id (^)(id obj))mapper;

@end

@interface NSMutableArray (MFHighOrder)

- (void)mfFilterWithTest:(BOOL (^)(id obj))test;
- (id)mfPopObjectPassingTest:(BOOL (^)(id obj))test;
- (id)mfPopObjectUsingPredicate:(NSPredicate *)predicate;

@end

@interface NSDictionary (MFHighOrder)

- (NSMutableDictionary *)mfDictionaryByRemovingKeysExcept:(id) key, ... NS_REQUIRES_NIL_TERMINATION;
- (NSMutableDictionary *)mfFilteredDictionaryWithTest:(BOOL (^)(id key, id object))test;
- (id)mfFold:(id)initialValue function:(void (^)(id initialValue, id key, id object))block;
// mapper can return a new object to add for that key or nil to no longer have that key
- (NSMutableDictionary *)mfMap:(id (^)(id key, id object))mapper;

@end

@interface NSMutableDictionary (MFHighOrder)

- (void)mfFilterWithTest:(BOOL (^)(id key, id object))test;
- (id)mfPopObjectForKey:(id)key;

@end