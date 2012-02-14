//
//  MFITunesAffiliateLinks.m
//  zabbi
//
//  Created by Jason Gregori on 1/18/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFITunesAffiliateLinks.h"

@implementation MFITunesAffiliateLinks

static NSDictionary *_linkShareParams;
+ (void)setLinkShareSiteID:(NSString *)siteID {
    if (siteID) {
        _linkShareParams = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"30", @"partnerId",
                            siteID, @"siteID",
                            nil];
    }
    else {
        _linkShareParams = nil;
    }
}

+ (NSString *)linkShareSiteID {
    return [_linkShareParams valueForKey:@"siteID"];
}

+ (NSString *)generateAffiliateLink:(NSString *)url {
    NSString *countryCode = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];
    
    //===== reroute to this users country
    // regex explanation: "itunes.apple.com" followed by (and matched) '/' + an optional (two letters + '/')
    //   there will be a match as long as there is a '/' after the ".com"
    //   the match will either be "/" or "/us/" or whatever two letters
    NSTextCheckingResult *countryMatch = [[NSRegularExpression regularExpressionWithPattern:@"itunes.apple.com(\\/(?:[a-z]{2}\\/)?)"
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:NULL]
                                          firstMatchInString:url options:0 range:NSMakeRange(0, [url length])];
    if ([countryMatch numberOfRanges] >= 2 && [countryMatch rangeAtIndex:1].location != NSNotFound) {
        url = [url stringByReplacingCharactersInRange:[countryMatch rangeAtIndex:1]
                                           withString:[NSString stringWithFormat:@"/%@/", countryCode]];
    }
    
    //===== affiliate params
    NSDictionary *params;
    // link share
    if ([[NSSet setWithObjects:@"ca", @"us", @"mx", nil] containsObject:countryCode]) {
        params = _linkShareParams;
    }
    
    if (params) {
        NSMutableArray *pairs = [NSMutableArray array];
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }];
        url = [NSString stringWithFormat:@"%@%@%@", url, ([url rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&"), [pairs componentsJoinedByString:@"&"]];
    }
    
    return url;
}

+ (BOOL)localeSupportsITunesMusic {
//    return [[NSSet setWithObjects:
//             
//             , nil
    return YES;
}

+ (BOOL)localeSupportsAffiliateLinks {
    return YES;
}

@end
