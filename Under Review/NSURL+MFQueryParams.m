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

static inline NSString *unescapeString(NSString *string) {
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapes(NULL,
                                                                                    (__bridge CFStringRef)string,
                                                                                    CFSTR(""));
}

+ (NSString *)mfURLStringWithString:(NSString *)url andParams:(NSDictionary *)params {
    if ([params count] == 0) {
        return url;
    }
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [[params allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", escapeString(key), escapeString([[params objectForKey:key] description])]];
    }
    return [NSString stringWithFormat:@"%@%@%@", url, ([url rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&"), [pairs componentsJoinedByString:@"&"]];
}

+ (id)mfURLWithString:(NSString *)url andParams:(NSDictionary *)params {
    return [NSURL URLWithString:[self mfURLStringWithString:url andParams:params]];
}

- (NSDictionary *)mfQueryParams {
    return [NSURL mfQueryParamsFromString:[self absoluteString]];
}

+ (NSDictionary *)mfQueryParamsFromString:(NSString *)string {
    // query params start at the '?'
    NSRange questionmarkRange = [string rangeOfString:@"?"];
    if (questionmarkRange.location == NSNotFound) {
        // there are no params
        return nil;
    }
    
    // query params end at the end of the url or at a '#'
    NSRange queryStringRange = NSMakeRange(NSMaxRange(questionmarkRange), string.length - NSMaxRange(questionmarkRange));
    
    NSRange hashtagRange = [string rangeOfString:@"#"];
    if (hashtagRange.location != NSNotFound
        && hashtagRange.location > queryStringRange.location) {
        // the hashtag cuts off the query params
        queryStringRange.length = hashtagRange.location - queryStringRange.location;
    }
    
    NSString *queryString = [string substringWithRange:queryStringRange];
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    // get param pairs
    for (NSString *pair in [queryString componentsSeparatedByString:@"&"]) {
        NSArray *keyAndObject = [pair componentsSeparatedByString:@"="];
        if (keyAndObject.count >= 2) {
            // unescape key and object
            NSString *key = unescapeString([keyAndObject objectAtIndex:0]);
            NSString *object = unescapeString([keyAndObject objectAtIndex:1]);
            if (key.length && object.length) {
                [params setValue:object forKey:key];
            }
        }
    }
    
    return params.count ? params : nil;
}

@end
