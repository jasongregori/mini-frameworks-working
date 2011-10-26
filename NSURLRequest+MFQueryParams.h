//
//  NSURLRequest+MFQueryParams.h
//  zabbi
//
//  Created by Jason Gregori on 7/22/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (MFQueryParams)

+ (id)mfRequestWithURL:(NSString *)url andParams:(NSDictionary *)params;

@end

@interface NSMutableURLRequest (MFQueryParams)

- (void)mfSetURL:(NSString *)url andParams:(NSDictionary *)params;

@end
