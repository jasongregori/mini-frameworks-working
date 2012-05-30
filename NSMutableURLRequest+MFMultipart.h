//
//  NSMutableURLRequest+MFMultipart.h
//  zabbi
//
//  Created by Jason Gregori on 10/25/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

// @mf: allows you to easily add multipart data to an NSMutableURLRequest

/*
 
 You may call these methods as many times as you want to add as much data as you want.
 Behavior is undefined if you mess with HTTPBody yourself and use these methods.
 
 */

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (MFMultipart)

- (void)mfAddMultiPartData:(NSData *)data withName:(NSString *)name type:(NSString *)type;
- (void)mfAddMultiPartData:(NSData *)data withName:(NSString *)name filename:(NSString *)filename type:(NSString *)type;
- (void)mfAddMultiPartData:(NSData *)data contentDisposition:(NSDictionary *)contentDisposition headers:(NSDictionary *)headers;

@end
