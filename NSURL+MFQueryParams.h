//
//  NSURL+MFQueryParams.h
//  zabbi
//
//  Created by Jason Gregori on 1/9/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (MFQueryParams)

+ (NSString *)mfURLStringWithString:(NSString *)string andParams:(NSDictionary *)params;
+ (id)mfURLWithString:(NSString *)string andParams:(NSDictionary *)params;

@end
