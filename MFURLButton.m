//
//  MFURLButton.m
//  zabbi
//
//  Created by Jason Gregori on 7/27/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFURLButton.h"

@interface MFURLButton ()
@property (nonatomic, strong) id connectionRef;
@end

@implementation MFURLButton
@synthesize url = __url;
@synthesize connectionRef = __connectionRef;

- (void)setUrl:(NSString *)url {
    if (__url != url) {
        __url = [url copy];
        
        self.connectionRef = nil;
        [self setImage:nil forState:UIControlStateNormal];
        if (__url) {
            __unsafe_unretained MFURLButton *weakSelf = self;
            self.connectionRef = [NSURLConnection mfGetImage:url
                                                   withBlock:^(UIImage *image, NSError *error) {
                                                       [self setImage:image forState:UIControlStateNormal];
                                                       weakSelf.connectionRef = nil;
                                                   }];
        }
    }
}

@end
