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

@implementation NSDictionary (__MFFacebookFriends_Friend)
- (NSString *)__MFFacebookFriends_SortByFirstNameString {
    return [[[self objectsForKeys:[NSArray arrayWithObjects:@"first_name", @"last_name", nil] notFoundMarker:@""]
             componentsJoinedByString:@" "]
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
- (NSString *)__MFFacebookFriends_SortByLastNameString {
    return [[[self objectsForKeys:[NSArray arrayWithObjects:@"last_name", @"first_name", nil] notFoundMarker:@""]
             componentsJoinedByString:@" "]
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
@end

@implementation MFFacebookFriends
@synthesize facebook;
@synthesize informationToGather;

- (id)init {
    self = [super init];
    if (self) {
        self.informationToGather = [NSArray arrayWithObjects:@"is_app_user", @"pic_square", @"name", nil];
    }
    return self;
}

- (NSDate *)lastRefreshedDate {
    return __lastRefreshedDate;
}

- (id)getFriends:(void (^)(NSArray *friends, NSString *error))block {
    if (__friendsAreLoaded) {
        if (block) {
            block(__friends, nil);
        }
        return nil;
    }
    return [self refreshFriends:block];
}

- (id)refreshFriends:(void (^)(NSArray *friends, NSString *error))block {
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
        NSString *fql = [NSString stringWithFormat:@"SELECT first_name, last_name, uid %@ FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me())",
                         ([self.informationToGather count]
                          ? [self.informationToGather componentsJoinedByString:@", "]
                          : @"")];
        __friendsRequest = [self.facebook requestWithGraphPath:@"fql"
                                                     andParams:[NSDictionary dictionaryWithObject:fql
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
    if (![result isKindOfClass:[NSArray class]]
        || [result count] == 0) {
        result = nil;
    }
    // sort the friends
    BOOL sortByFirstName = ABPersonGetSortOrdering() == kABPersonSortByFirstName;
    NSArray *friends = [result sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (sortByFirstName) {
            return [[obj1 __MFFacebookFriends_SortByFirstNameString]
                    localizedCompare:
                    [obj2 __MFFacebookFriends_SortByFirstNameString]];
        }
        return [[obj1 __MFFacebookFriends_SortByLastNameString]
                localizedCompare:
                [obj2 __MFFacebookFriends_SortByLastNameString]];
    }];
    
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