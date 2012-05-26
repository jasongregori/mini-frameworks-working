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
#import <objc/runtime.h>

@interface __MFFacebookFriends_OnDealloc : NSObject
@property (copy) void (^performOnDeallocBlock)();
+ (id)performOnDealloc:(void (^)())block;
@end

@interface MFFacebookFriends () <FBRequestDelegate> {
    BOOL __cacheCleared;
    NSMutableArray *__friends;
    BOOL __friendsAreLoaded;
    NSCountedSet *__friendsLoadBlocks;
    FBRequest *__friendsRequest;
    NSDate *__lastRefreshedDate;    
}
@property (nonatomic, unsafe_unretained) Facebook *facebook;
@end

@implementation Facebook (MFFacebookFriends)

- (MFFacebookFriends *)mfFriends {
    MFFacebookFriends *f;
    static char associationKey;
    f = objc_getAssociatedObject(self, &associationKey);
    if (!f) {
        f = [MFFacebookFriends new];
        f.facebook = self;
        objc_setAssociatedObject(self, &associationKey, f, OBJC_ASSOCIATION_RETAIN);
    }
    return f;
}

@end

@implementation MFFacebookFriends
@synthesize facebook;
@synthesize informationToGather;

- (id)init {
    self = [super init];
    if (self) {
        self.informationToGather = [NSArray arrayWithObjects:@"is_app_user", @"pic_square", @"name", nil];
        __friendsLoadBlocks = [NSCountedSet set];
    }
    return self;
}

- (NSDate *)lastRefreshedDate {
    return __lastRefreshedDate;
}

- (id)getFriends:(BOOL)forceRefresh block:(void (^)(NSArray *friends, NSString *error))block {
    if (!forceRefresh && __friendsAreLoaded) {
        if (block) {
            block(__friends, nil);
        }
        return nil;
    }
    
    __cacheCleared = NO;
    
    void (^loadBlock)(NSArray *friends, NSString *error) = [block copy];
    if (loadBlock) {
        [__friendsLoadBlocks addObject:loadBlock];
    }
    
    if (!__friendsRequest) {
        NSString *fql = [NSString stringWithFormat:@"SELECT first_name, last_name, uid%@ FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me())",
                         ([self.informationToGather count]
                          ? [@", " stringByAppendingString:[self.informationToGather componentsJoinedByString:@", "]]
                          : @"")];
        __friendsRequest = [self.facebook requestWithGraphPath:@"fql"
                                                     andParams:[NSMutableDictionary dictionaryWithObject:fql
                                                                                                  forKey:@"q"]
                                                   andDelegate:self];
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
- (void)clearCachedFriends {
    __cacheCleared = YES;
    __friends = nil;
    __friendsAreLoaded = NO;
    __lastRefreshedDate = nil;
}

#pragma mark - FBRequestDelegate

- (void)request:(FBRequest *)request didLoad:(id)result {
    // make sure we get an array back
    if (![result isKindOfClass:[NSDictionary class]]
        || [result count] == 0) {
        result = nil;
    }
    result = [result valueForKey:@"data"];
    if (![result isKindOfClass:[NSArray class]]
        || [result count] == 0) {
        result = nil;
    }
    // sort the friends    
    NSArray *friends = [result sortedArrayUsingSelector:
                        (ABPersonGetSortOrdering() == kABPersonSortByFirstName
                         ? @selector(mfFacebookFriendCompareByFirstName:)
                         : @selector(mfFacebookFriendCompareByLastName:))];
    
    if (!__cacheCleared) {
        // if the cache is cleared dont cache these
        __friends = [friends mutableCopy];
        __friendsAreLoaded = YES;
        __lastRefreshedDate = [NSDate date];
    }
    for (void (^loadBlock)(NSArray *friends, NSString *error) in __friendsLoadBlocks) {
        loadBlock(friends, nil);
    }
    [__friendsLoadBlocks removeAllObjects];
    
    __friendsRequest = nil;
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    for (void (^loadBlock)(NSArray *friends, NSString *error) in __friendsLoadBlocks) {
        loadBlock(nil, [error localizedDescription]);
    }
    [__friendsLoadBlocks removeAllObjects];
    
    __friendsRequest = nil;
}

@end


#pragma mark - MFFacebookFriend NSDictionary

@implementation NSDictionary (MFFacebookFriend)
- (NSComparisonResult)mfFacebookFriendCompareByFirstName:(NSDictionary *)aFriend {
    return [[self mfFacebookFriendSortStringFirstName] localizedCaseInsensitiveCompare:
            [aFriend mfFacebookFriendSortStringFirstName]];
}
- (NSString *)mfFacebookFriendSortStringFirstName {
    return [[[self objectsForKeys:[NSArray arrayWithObjects:@"first_name", @"last_name", nil] notFoundMarker:@""]
             componentsJoinedByString:@" "]
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
- (NSComparisonResult)mfFacebookFriendCompareByLastName:(NSDictionary *)aFriend {
    return [[self mfFacebookFriendSortStringLastName] localizedCaseInsensitiveCompare:
            [aFriend mfFacebookFriendSortStringLastName]];
}
- (NSString *)mfFacebookFriendSortStringLastName {
    return [[[self objectsForKeys:[NSArray arrayWithObjects:@"last_name", @"first_name", nil] notFoundMarker:@""]
             componentsJoinedByString:@" "]
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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