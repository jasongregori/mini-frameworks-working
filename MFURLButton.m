//
//  MFURLButton.m
//  zabbi
//
//  Created by Jason Gregori on 7/27/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFURLButton.h"

@interface MFURLButton ()
@property (nonatomic, retain) id connectionRef;
@end

@implementation MFURLButton
@synthesize url = __url;
@synthesize connectionRef = __connectionRef;

- (void)dealloc {
    self.url = nil;
    self.connectionRef = nil;
    
    [super dealloc];
}

- (void)setUrl:(NSString *)url {
    if (__url != url) {
        [__url release];
        __url = [url copy];
        
        if (__url) {
            __block MFURLButton *weakSelf = self;
            self.connectionRef = [NSURLConnection mfGetImage:url
                                                   withBlock:^(UIImage *image, NSError *error) {
                                                       weakSelf.imageView.image = image;
                                                       weakSelf.connectionRef = nil;
                                                   }];
        }
    }
}

@end
