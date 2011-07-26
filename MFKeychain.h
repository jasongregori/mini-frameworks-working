//
//  MFKeychain.h
//  zabbi
//
//  Created by Jason Gregori on 7/25/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: Securely stores whatever you want using the Keychain

/*
 
 Uses a keyed archiver to turn your object into data.
 Uses your key as the service and your bundle id as the account.
 
 */

#import <Foundation/Foundation.h>

@interface MFKeychain : NSObject

+ (BOOL)setObject:(id)object withKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

@end
