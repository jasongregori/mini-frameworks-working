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
 - By default the first_name, last_name, and uid are gathered for each friend.
   You can add more information to gather by setting `informationToGather` (it defaults to is_app_user, pic_square, and name).
   See https://developers.facebook.com/docs/reference/fql/user/ for keys.
 
 */

@class MFFacebookFriends;

@interface Facebook (MFFacebookFriends)
@property (nonatomic, readonly) MFFacebookFriends *mfFriends;
@end

@interface MFFacebookFriends : NSObject
@property (nonatomic, copy) NSArray *informationToGather;

- (NSDate *)lastRefreshedDate;

// this method will get the users' friends.
// we use the cache if possible and forceRefresh is NO, otherwise this method will download them.
// retain the object returned, if you release the object, your block will not be called.
- (id)getFriends:(BOOL)forceRefresh block:(void (^)(NSArray *friends, NSString *error))block;

// this will clear the cached friends. current requests will still finish but their results will not be cached.
- (void)clearCachedFriends;

@end

/*
 These methods are here to help you sort the friends.
 */
@interface MFFacebookFriend : NSDictionary
- (NSComparisonResult)mfFacebookFriendCompareByFirstName:(MFFacebookFriend *)aFriend;
- (NSString *)mfFacebookFriendSortStringFirstName;
- (NSComparisonResult)mfFacebookFriendCompareByLastName:(MFFacebookFriend *)aFriend;
- (NSString *)mfFacebookFriendSortStringLastName;
@end