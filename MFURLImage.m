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
    if (__url != url) {
        __url = [url copy];
        
        self.connectionRef = nil;
        self.image = nil;
        if (__url) {
            __unsafe_unretained MFURLImageView *weakSelf = self;
            self.connectionRef = [NSURLConnection mfGetImage:url
                                                   withBlock:^(UIImage *image, NSError *error) {
                                                       weakSelf.image = image;
                                                       weakSelf.connectionRef = nil;
                                                   }];
        }
    }
}

@end
