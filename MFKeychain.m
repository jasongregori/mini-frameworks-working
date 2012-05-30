//
//  MFKeychain.m
//  zabbi
//
//  Created by Jason Gregori on 7/25/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFKeychain.h"

#import <Security/Security.h>

#define commonAttributes key, kSecAttrService, [[NSBundle mainBundle] bundleIdentifier], kSecAttrAccount, kSecClassGenericPassword, kSecClass

@implementation MFKeychain

+ (BOOL)setObject:(id)object withKey:(NSString *)key {
    if (object) {
        // ## storing data
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        
        // first try to straight up add
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                                commonAttributes,
                                                                data, kSecValueData,
                                                                nil],
                                     NULL);
        
        if (status == errSecDuplicateItem) {
            // try an update
            status = SecItemUpdate((__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                              commonAttributes,
                                                              nil],
                                   (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                              data, kSecValueData,
                                                              nil]);
        }
        
        return status == errSecSuccess;
    }
    else {
        // ## erasing data
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   commonAttributes,
                                                                   nil]);
        return status == errSecSuccess;
    }
}

+ (id)objectForKey:(NSString *)key {
    CFTypeRef dataRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     commonAttributes,
                                                                     kCFBooleanTrue, kSecReturnData,
                                                                     nil],
                                          &dataRef);
    NSData *data = (__bridge_transfer NSData *)dataRef;
    if (status == errSecSuccess && data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

@end