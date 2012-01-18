//
//  NSURL+MFQueryParams.m
//  zabbi
//
//  Created by Jason Gregori on 1/9/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "NSURL+MFQueryParams.h"

@implementation NSURL (MFQueryParams)

static inline NSString *escapeString(NSString *string) {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8);
}

+ (NSString *)mfURLStringWithString:(NSString *)url andParams:(NSDictionary *)params {
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in params) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", escapeString(key), escapeString([[params objectForKey:key] description])]];
    }
    return [NSString stringWithFormat:@"%@%@%@", url, ([url rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&"), [pairs componentsJoinedByString:@"&"]];
}

+ (id)mfURLWithString:(NSString *)url andParams:(NSDictionary *)params {
    return [NSURL URLWithString:[self mfURLStringWithString:url andParams:params]];
}

@end
