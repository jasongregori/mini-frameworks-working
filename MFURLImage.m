//
//  MFURLImageView.m
//  zabbi
//
//  Created by Jason Gregori on 7/22/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFURLImage.h"

@interface MFURLImageView ()
@property (nonatomic, strong) id connectionRef;
@end

@implementation MFURLImageView
@synthesize url = __url;
@synthesize connectionRef = __connectionRef;

- (void)setUrl:(NSString *)url {
    if (![__url isEqualToString:url]) {
        __url = [url copy];
        
        [self refresh];
    }
}

- (void)refresh {
    self.connectionRef = nil;
    self.image = nil;
    if (self.url) {
        __unsafe_unretained MFURLImageView *weakself = self;
        self.connectionRef = [NSURLConnection mfGetImage:self.url
                                               withBlock:^(UIImage *image, NSError *error) {
                                                   weakself.image = image;
                                                   weakself.connectionRef = nil;
                                               }];
    }
}

@end
