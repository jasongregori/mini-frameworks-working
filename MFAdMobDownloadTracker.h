//
//  MFAdMobDownloadTracker.h
//  zabbi
//
//  Created by Jason Gregori on 1/25/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

// @mf: Tracks app downloads for AdMob

/*
 
 Call this method in your applicationDidFinishingLaunching... method.
 
 A lot of the code is taken from AdMob: http://support.google.com/admob/bin/answer.py?hl=en&topic=1623717&answer=1704628
 
 */

#import <Foundation/Foundation.h>

@interface MFAdMobDownloadTracker : NSObject

+ (void)trackDownloadForApp:(NSString *)appID;

@end
