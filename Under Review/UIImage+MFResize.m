//
//  UIImage+MFResize.m
//  zabbi
//
//  Created by Jason Gregori on 10/26/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "UIImage+MFResize.h"

@implementation UIImage (MFResize)

- (UIImage *)mfResizedImageWithSize:(CGSize)size {
    
    if (size.width > self.size.width && size.height > self.size.height) {
        return self;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(floor(size.width), floor(size.height)));
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)mfResizedImageWithSmallSide:(CGFloat)smallSide {
    CGFloat ratio = smallSide / MIN(self.size.width, self.size.height);
    return [self mfResizedImageWithSize:CGSizeMake(self.size.width * ratio, self.size.height * ratio)];
}

@end
