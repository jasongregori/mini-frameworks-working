//
//  MFFacebookFriends.m
//  zabbi
//
//  Created by Jason Gregori on 1/25/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFFacebookFriends.h"

#import "Facebook.h"

#import <AddressBook/AddressBook.h>

@interface __MFFacebookFriends_OnDealloc : NSObject
@property (copy) void (^performOnDeallocBlock)();
+ (id)performOnDealloc:(void (^)())block;
@end

@implementation MFFacebookFriends

static BOOL __cacheCleared;
static NSMutableArray *__friends;
static BOOL __friendsAreLoaded;
static NSCountedSet *__friendsLoadBlocks;
static FBRequest *__friendsRequest;
static NSDate *__lastRefreshedDate;

+ (NSDate *)lastRefreshedDate {
    return __lastRefreshedDate;
}

+ (id)getFriends:(void (^)(NSArray *friends, NSString *error))block {
    if (__friendsAreLoaded) {
        if (block) {
            block(__friends, nil);
        }
        return nil;
    }
    return [self refreshFriends:block];
}

+ (id)refreshFriends:(void (^)(NSArray *friends, NSString *error))block {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __friendsLoadBlocks = [NSCountedSet set];
    });
    
    __cacheCleared = NO;
    
    void (^loadBlock)(NSArray *friends, NSString *error) = [block copy];
    if (loadBlock) {
        [__friendsLoadBlocks addObject:loadBlock];
    }
    
    if (!__friendsRequest) {
        __friendsRequest = [Facebook 
        
        
        __friendsRequest = [[ZAZabbiAPI api] requestWithPath:@"friends"
                                                         params:nil
                                                          block:^(id result, NSString *error) {
                                                              // make sure we get an array back
                                                              if (![result isKindOfClass:[NSArray class]]
                                                                  || [result count] == 0) {
                                                                  result = nil;
                                                              }
                                                              // sort the friends
                                                              BOOL sortByFirstName = ABPersonGetSortOrdering() == kABPersonSortByFirstName;
                                                              NSArray *friends = [result sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                  if (sortByFirstName) {
                                                                      return [[obj1 zaExpressionCreatorSortStringForFirstName]
                                                                              localizedCompare:
                                                                              [obj2 zaExpressionCreatorSortStringForFirstName]];
                                                                  }
                                                                  return [[obj1 zaExpressionCreatorSortStringForLastName]
                                                                          localizedCompare:
                                                                          [obj2 zaExpressionCreatorSortStringForLastName]];
                                                              }];
                                                              
                                                              if (!__cacheCleared) {
                                                                  // if the cache is cleared dont cache these
                                                                  __friends = [friends mutableCopy];
                                                                  __friendsAreLoaded = YES;
                                                                  __lastRefreshedDate = [NSDate date];
                                                              }
                                                              for (void (^loadBlock)(NSArray *friends, NSString *error) in __friendsLoadBlocks) {
                                                                  loadBlock(friends, error);
                                                              }
                                                              [__friendsLoadBlocks removeAllObjects];
                                                              
                                                              __friendsRequest = nil;
                                                          }];    
    }
    
    if (loadBlock) {
        // if you dealloc this object, the load block is released
        return [__MFFacebookFriends_OnDealloc performOnDealloc:^{
            [__friendsLoadBlocks removeObject:loadBlock];
        }];
    }
    return nil;
}

// this will clear the cached friends. current requests will still finish but their results will not be cached.
+ (void)clearCachedFriends {
    __cacheCleared = YES;
    __friends = nil;
    __friendsAreLoaded = NO;
    __lastRefreshedDate = nil;
}

@end


#pragma mark -  __MFFacebookFriends_OnDealloc 

@implementation __MFFacebookFriends_OnDealloc
@synthesize performOnDeallocBlock = __performOnDeallocBlock;

+ (id)performOnDealloc:(void (^)())block {
    __MFFacebookFriends_OnDealloc *o = [[__MFFacebookFriends_OnDealloc alloc] init];
    o.performOnDeallocBlock = block;
    return o;
}

- (void)dealloc {
    if (self.performOnDeallocBlock) {
        if ([NSThread isMainThread]) {
            self.performOnDeallocBlock();
        }
        else {
            dispatch_sync(dispatch_get_main_queue(), ^ { self.performOnDeallocBlock(); });
        }
    }
}

@end