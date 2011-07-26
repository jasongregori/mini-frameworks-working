//
//  MFKeychainTests.m
//  MFTests
//
//  Created by Jason Gregori on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MFKeychainTests.h"

@implementation MFKeychainTests

#define key @"#1"
#define key2 @"#2"
#define string @"test string"
#define string2 @"asdf"

- (void)setUp {
    // delete any old keychains
    [MFKeychain setObject:nil withKey:key];
    [MFKeychain setObject:nil withKey:key2];
}

- (void)testSettingAndGettingADictionary {
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:@"a", @"1", @"b", @"2", nil];
    [MFKeychain setObject:d withKey:key];
    STAssertEqualObjects(d, [MFKeychain objectForKey:key], @"The item set was not the item received");
}

- (void)testSettingAndGetting {
    [MFKeychain setObject:string withKey:key];
    STAssertEqualObjects(string, [MFKeychain objectForKey:key], @"The item set was not the item received");
}

- (void)testErasingObjects {
    [MFKeychain setObject:string withKey:key];
    [MFKeychain setObject:nil withKey:key];
    STAssertNil([MFKeychain objectForKey:key], @"This should have erased what was stored in there");
}

- (void)testOverridingObjects {
    [MFKeychain setObject:string withKey:key];
    [MFKeychain setObject:string2 withKey:key];
    STAssertEqualObjects(string2, [MFKeychain objectForKey:key], @"Object was not overridden");
}

- (void)testStoringMultipleObjects {
    [MFKeychain setObject:string withKey:key];
    [MFKeychain setObject:string2 withKey:key2];
    STAssertEqualObjects(string, [MFKeychain objectForKey:key], @"setting object 2 overrode object 1!");
    STAssertEqualObjects(string2, [MFKeychain objectForKey:key2], @"object 2 was not set properly!");
}

@end
