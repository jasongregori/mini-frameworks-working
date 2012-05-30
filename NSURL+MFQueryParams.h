//
//  NSURL+MFQueryParams.h
//  zabbi
//
//  Created by Jason Gregori on 1/9/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

// @mf: create urls with query params or get query params from a url

#import <Foundation/Foundation.h>

@interface NSURL (MFQueryParams)

// creating
+ (NSString *)mfURLStringWithString:(NSString *)string andParams:(NSDictionary *)params;
+ (id)mfURLWithString:(NSString *)string andParams:(NSDictionary *)params;

// getting
- (NSDictionary *)mfQueryParams;
+ (NSDictionary *)mfQueryParamsFromString:(NSString *)string;

@end
