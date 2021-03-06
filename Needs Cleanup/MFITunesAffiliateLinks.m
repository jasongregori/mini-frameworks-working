//
//  MFITunesAffiliateLinks.m
//  zabbi
//
//  Created by Jason Gregori on 1/18/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFITunesAffiliateLinks.h"

#define kDGM @"dgm"
#define kLinkShareAmericas @"linkshare americas"
#define kLinkShareJapan @"linkshare japan"
#define kTradeDoublerBrazil @"trade doubler brazil"
#define kTradeDoublerEurope @"trade doubler europe"

@interface MFITunesAffiliateLinks ()
+ (NSDictionary *)__affiliateNetworksToCountries;
+ (NSString *)__countryCode;
@end

@implementation MFITunesAffiliateLinks

static NSMutableDictionary *_affiliateNetworksToParams;
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _affiliateNetworksToParams = [NSMutableDictionary dictionary];
    });
}


#pragma mark - Static Information

// the list of itunes affiliate networks and countries were retreived Feb 14, 2012 from this site: http://en.wikipedia.org/wiki/ITunes_Store#Internationalization
+ (NSDictionary *)__affiliateNetworksToCountries {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            
            [NSSet setWithObjects:@"au", @"nz", nil],
            kDGM,
            
            [NSSet setWithObjects:@"ca", @"mx", @"us", nil],
            kLinkShareAmericas,
            
            [NSSet setWithObjects:@"jp", nil],
            kLinkShareJapan,
            
            [NSSet setWithObjects:@"br", nil],
            kTradeDoublerBrazil,
            
            [NSSet setWithObjects:@"at", @"be", @"bg", @"ch", @"cy", @"cz", @"de", @"dk", @"ee", @"es", @"fi", @"fr", @"gb", @"gr", @"hu", @"ie", @"it", @"lt", @"lu", @"lv", @"mt", @"nl", @"no", @"pl", @"pt", @"ro", @"se", @"si", @"sk", nil],
            kTradeDoublerEurope,
            
            nil];
}

+ (NSString *)__countryCode {
    return [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];
//    return @"br";
}

#pragma mark - Affiliate Params

+ (void)setDGMAffiliateToken:(NSString *)affiliateToken {
    if (affiliateToken) {
        [_affiliateNetworksToParams setObject:[NSString stringWithFormat:@"partnerId=1002&affToken=%@", affiliateToken]
                                       forKey:kDGM];
    }
    else {
        [_affiliateNetworksToParams removeObjectForKey:kDGM];
    }
}

+ (void)setLinkShareAmericasSiteID:(NSString *)siteID {
    if (siteID) {
        [_affiliateNetworksToParams setObject:[NSString stringWithFormat:@"partnerId=30&siteID=%@", siteID]
                                       forKey:kLinkShareAmericas];
    }
    else {
        [_affiliateNetworksToParams removeObjectForKey:kLinkShareAmericas];
    }
}

+ (void)setTradeDoublerBrazilTDUID:(NSString *)tduid andAffID:(NSString *)affId {
    if (tduid && affId) {
        [_affiliateNetworksToParams setObject:[NSString stringWithFormat:@"partnerId=2003&tduid=%@&affId=%@", tduid, affId]
                                       forKey:kTradeDoublerBrazil];
    }
    else {
        [_affiliateNetworksToParams removeObjectForKey:kTradeDoublerBrazil];
    }
}

#pragma mark - Generate Links

+ (NSString *)generateAffiliateLink:(NSString *)url {
    NSString *countryCode = [self __countryCode];
    
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
    __block NSString *params;
    [[self __affiliateNetworksToCountries] enumerateKeysAndObjectsUsingBlock:^(NSString *affiliateNetwork, NSSet *countries, BOOL *stop) {
        if ([countries containsObject:countryCode]) {
            params = [_affiliateNetworksToParams objectForKey:affiliateNetwork];
            *stop = YES;
        }
    }];
    
    if (params) {
        url = [NSString stringWithFormat:@"%@%@%@", url, ([url rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&"), params];
    }
    
    return url;
}

#pragma mark - Locale Support

// the list of music countries was retreived Feb 14, 2010 from http://en.wikipedia.org/wiki/ITunes_Store#Internationalization
+ (BOOL)localeSupportsITunesMusic {
    static BOOL supports = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *country = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];
        supports = [[NSSet setWithObjects:@"ar", @"at", @"au", @"be", @"bg", @"bo", @"br", @"ca", @"ch", @"cl", @"co", @"cr", @"cy", @"cz", @"de", @"dk", @"do", @"ec", @"ee", @"es", @"fi", @"fr", @"gb", @"gr", @"gt", @"hn", @"hu", @"ie", @"it", @"jp", @"lt", @"lu", @"lv", @"mt", @"mx", @"ni", @"nl", @"no", @"nz", @"pa", @"pe", @"pl", @"pt", @"py", @"ro", @"se", @"si", @"sk", @"sv", @"us", @"ve", nil]
                    containsObject:country];
    });
    return supports;
}

+ (BOOL)localeSupportsAffiliateLinks {
    static BOOL supports = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *country = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];
        [[self __affiliateNetworksToCountries] enumerateKeysAndObjectsUsingBlock:^(NSString *affiliateNetwork, NSSet *countries, BOOL *stop) {
            if ([countries containsObject:country]) {
                *stop = YES;
                supports = YES;
            }
        }];
    });
    return supports;
}

@end
