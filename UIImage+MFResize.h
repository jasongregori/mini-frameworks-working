//
//  UIImage+MFResize.h
//  zabbi
//
//  Created by Jason Gregori on 10/26/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

// @mf: Easily resize an image. Thread safe (I think).

/*
 
 • These methods will only resize an image smaller, if the size is larger than the image the original will be returned. 
 • If the size is not a whole number the image will get slightly cropped
 • I think this is thread safe because of this: http://developer.apple.com/library/ios/#releasenotes/General/WhatsNewIniPhoneOS/Articles/iPhoneOS4.html
 
 */

#import <UIKit/UIKit.h>

@interface UIImage (MFResize)

- (UIImage *)mfResizedImageWithSize:(CGSize)size;
- (UIImage *)mfResizedImageWithSmallSide:(CGFloat)smallSide;

@end
