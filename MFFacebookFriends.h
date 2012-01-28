//
//  MFFacebookFriends.h
//  zabbi
//
//  Created by Jason Gregori on 1/25/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

// @mf: An api for caching facebook friends

#import <Foundation/Foundation.h>
#import "Facebook.h"

/*
 
 - Use the category method to get the mfFriends instance.
 - Friends are always returned alphabetized according to the user's contact settings.
 - By default, information gathered for each friend are is_app_user, first_name, last_name, uid, pic_square, and name.
   You can change it by setting `informationToGather`. See https://developers.facebook.com/docs/reference/fql/user/ for keys.
 
 */

@class MFFacebookFriends;

@interface Facebook (MFFacebookFriends)
@property (nonatomic, readonly) MFFacebookFriends *mfFriends;
@end

@interface MFFacebookFriends : NSObject
@property (nonatomic, copy) NSArray *informationToGather;

- (NSDate *)lastRefreshedDate;

// this method will give you the cached friends. if they aren't loaded, this will load them.
// retain the object returned, if you release the object, your block will not be called.
- (id)getFriends:(void (^)(NSArray *friends, NSString *error))block;
// this method will reload friends even if they are cached.
// retain the object returned, if you release the object, your block will not be called.
- (id)refreshFriends:(void (^)(NSArray *friends, NSString *error))block;

// this will clear the cached friends. current requests will still finish but their results will not be cached.
- (void)clearCachedFriends;

@end
