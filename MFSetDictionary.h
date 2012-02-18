//
//  MFSetDictionary.h
//  zabbi
//
//  Created by Jason Gregori on 1/10/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFSetDictionary : NSObject
- (void)addObject:(id)object forKey:(id)key; // keys must conform to the NSCopying protocol
- (void)removeObject:(id)object forKey:(id)key;

- (NSSet *)allObjectsForKey:(id)key;
- (NSUInteger)countForKey:(id)key;
- (void)removeAllObjectsForKey:(id)key;

- (void)enumerateObjectsForKey:(id)key usingBlock:(void (^)(id obj, BOOL *stop))block;

- (id)popObjectForKey:(id)key;
@end
