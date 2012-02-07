//
//  MFAdMobDownloadTracker.m
//  zabbi
//
//  Created by Jason Gregori on 1/25/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFAdMobDownloadTracker.h"

#import <CommonCrypto/CommonDigest.h>

#define kHasTrackedDownloadKey @"admob_has_tracked_download"

@implementation MFAdMobDownloadTracker

+ (void)trackDownloadForApp:(NSString *)appID {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // check if we've already tracked this app
        if ([defaults boolForKey:kHasTrackedDownloadKey]) {
            return;
        }
        
        // get hashed uid
        NSString *isu = [UIDevice currentDevice].uniqueIdentifier;
        
        unsigned char digest[16];
        NSData *isuData = [isu dataUsingEncoding:NSASCIIStringEncoding];
        CC_MD5([isuData bytes], [isuData length], digest);
        
        NSString *hashedISU = [[NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                digest[0], digest[1], 
                                digest[2], digest[3],
                                digest[4], digest[5],
                                digest[6], digest[7],
                                digest[8], digest[9],
                                digest[10], digest[11],
                                digest[12], digest[13],
                                digest[14], digest[15]]
                               uppercaseString];
        
        // send the request
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:
                                  [NSString stringWithFormat:@"http://a.admob.com/f0?isu=%@&md5=1&app_id=%@",
                                   hashedISU,
                                   appID]]];
        NSHTTPURLResponse *response;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        if(!error && [response statusCode] == 200 && [responseData length]) {
            // record success, otherwise we'll try again next time
            [defaults setBool:YES forKey:kHasTrackedDownloadKey];
            [defaults synchronize];
        }
    });
}

@end
