//
//  MFITunesAffiliateLinks.h
//  zabbi
//
//  Created by Jason Gregori on 1/18/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

// @mf: takes a simple itunes link. reroutes it to the user's countries store and adds affiliate link information.

/*
 
 This class only works with links of the form "http://itunes.apple.com/us/artist/blind-pilot/id284309952".
 We will reroute anything we find with these forms: "itunes.apple.com/us/bla" or "itunes.apple.com/bla".
 Affiliate params will be added to the end of the url.
 
 Currently we only support link share but the others will not be hard to add.
 
 See here on how all this works: http://www.apple.com/itunes/affiliates/resources/documentation/linking-to-the-itunes-music-store.html#CleanLinks
 
 TODO: get actual location to find country instead of using NSLocale
 
 */

#import <Foundation/Foundation.h>

@interface MFITunesAffiliateLinks : NSObject

+ (void)setDGMAffiliateToken:(NSString *)affiliateToken;
+ (void)setLinkShareAmericasSiteID:(NSString *)siteID;
+ (void)setTradeDoublerBrazilTDUID:(NSString *)tduid andAffID:(NSString *)affId;

+ (NSString *)generateAffiliateLink:(NSString *)url;

// These methods tell you if something is supported in the user's local
+ (BOOL)localeSupportsITunesMusic;
+ (BOOL)localeSupportsAffiliateLinks;

@end
