//
//  NSMutableURLRequest+MFMultipart.m
//  zabbi
//
//  Created by Jason Gregori on 10/25/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "NSMutableURLRequest+MFMultipart.h"

#define kBoundarySubString @"______0xMuLtIpArTbOuNdArYx0______"
#define kContentType @"multipart/form-data; boundary=" kBoundarySubString
#define kNewLine @"\r\n"
#define kBoundary @"--" kBoundarySubString kNewLine
#define kEndBoundary @"--" kBoundarySubString @"--" kNewLine

@implementation NSMutableURLRequest (MFMultipart)

- (void)mfAddMultiPartData:(NSData *)data withName:(NSString *)name type:(NSString *)type {
    [self mfAddMultiPartData:data withName:name filename:nil type:type];
}

- (void)mfAddMultiPartData:(NSData *)data withName:(NSString *)name filename:(NSString *)filename type:(NSString *)type {
    NSMutableDictionary *contentDispostion = [NSMutableDictionary dictionary];
    [contentDispostion setValue:name forKey:@"name"];
    [contentDispostion setValue:filename forKey:@"filename"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setValue:type forKey:@"Content-Type"];

    [self mfAddMultiPartData:data contentDisposition:contentDispostion headers:headers];
}

- (void)mfAddMultiPartData:(NSData *)data contentDisposition:(NSDictionary *)contentDisposition headers:(NSDictionary *)headers {
    NSMutableData *body = [self.HTTPBody mutableCopy];
    NSData *endBoundary = [kEndBoundary dataUsingEncoding:NSUTF8StringEncoding];
    
    // remove previous end boundary
    if (body) {
        if ([body length] > [endBoundary length] && [[body subdataWithRange:NSMakeRange([body length] - [endBoundary length], [endBoundary length])] isEqualToData:endBoundary]) {
            // this has an end boundary from earlier multipart data, remove the end part
            [body setLength:[body length] - [endBoundary length]];
        }
        else {
            // this must have been set by something else, reset the body
            body = nil;
        }
    }
    
    // set up new body
    if (!body) {
        [self setValue:kContentType forHTTPHeaderField:@"Content-Type"];
        [self setHTTPMethod:@"POST"];
        body = [NSMutableData data];
    }
    
    // add boundary
    [body appendData:[kBoundary dataUsingEncoding:NSUTF8StringEncoding]];
    
    // append content disposition
    NSMutableString *cd = [NSMutableString stringWithString:@"Content-Disposition: form-data"];
    for (NSString *key in contentDisposition) {
        [cd appendFormat:@"; %@=\"%@\"", key, [contentDisposition objectForKey:key]];
    }
    [cd appendString:kNewLine];
    [body appendData:[cd dataUsingEncoding:NSUTF8StringEncoding]];
    
    // append headers
    NSMutableString *hs = [NSMutableString string];
    for (NSString *key in headers) {
        [hs appendFormat:@"%@: %@%@", key, [headers objectForKey:key], kNewLine];
    }
    [body appendData:[hs dataUsingEncoding:NSUTF8StringEncoding]];
     
    // new line
    [body appendData:[kNewLine dataUsingEncoding:NSUTF8StringEncoding]];
    
    // actual data
    [body appendData:data];
    
    // new line
    [body appendData:[kNewLine dataUsingEncoding:NSUTF8StringEncoding]];

    // end boundary
    [body appendData:endBoundary];
    
    
    // reset body
    self.HTTPBody = body;
}

@end
