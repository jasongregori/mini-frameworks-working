//
//  UIView+MFBoundsAndFramesHelper.h
//  zabbi
//
//  Created by Jason Gregori on 10/7/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MFBoundsAndFramesHelper)

- (CGSize)mfSizeThatFitsAndIsAtMost:(CGSize)size;

@end