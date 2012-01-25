//
//  MFFacebookFriends.h
//  zabbi
//
//  Created by Jason Gregori on 1/25/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

// @mf: An api for caching facebook friends

#import <Foundation/Foundation.h>

/*
 
 Friendlies are always returned alphabetized according to the user's contact settings
 
 */

#error How am i going to know which Facebook to use?
// maybe just setFacebook:?
// another option is a category but that seems like a lot of work

@interface MFFacebookFriends : NSObject

+ (NSDate *)lastRefreshedDate;

// this method will give you the cached friends. if they aren't loaded, this will load them.
// retain the object returned, if you release the object, your block will not be called.
+ (id)getFriends:(void (^)(NSArray *friends, NSString *error))block;
// this method will reload friends even if they are cached.
// retain the object returned, if you release the object, your block will not be called.
+ (id)refreshFriends:(void (^)(NSArray *friends, NSString *error))block;

// this will clear the cached friends. current requests will still finish but their results will not be cached.
+ (void)clearCachedFriends;

@end
