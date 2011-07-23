//
//  NSURLRequest+MFParamsAndMultipart.m
//  zabbi
//
//  Created by Jason Gregori on 7/22/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "NSURLRequest+MFParamsAndMultipart.h"

static inline NSString *escapeString(NSString *string) {
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)string,
                                                               NULL,
                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                               kCFStringEncodingUTF8);
}

static NSURL *urlWithParams(NSString *url, NSDictionary *params) {
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in params) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", escapeString(key), escapeString([params objectForKey:key])]];
    }
    NSString *newURL = [NSString stringWithFormat:@"%@%@%@", url, ([url rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&"), [pairs componentsJoinedByString:@"&"]];
    return [NSURL URLWithString:newURL];
}

@implementation NSURLRequest (MFParamsAndMultipart)

+ (id)mfRequestWithURL:(NSString *)url andParams:(NSDictionary *)params {
    return [self requestWithURL:urlWithParams(url, params)];
}

@end

@implementation NSMutableURLRequest (MFParamsAndMultipart)

- (void)mfSetURL:(NSString *)url andParams:(NSDictionary *)params {
    [self setURL:urlWithParams(url, params)];
}

@end
