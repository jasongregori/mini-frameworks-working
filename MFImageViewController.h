//
//  MFImageViewController.h
//  zabbi
//
//  Created by Jason Gregori on 12/13/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFImageViewController : UIViewController
@property (nonatomic, strong) UIImage *image;
- (void)reset;
// this is a subview that goes on the top of the view, it does not zoom and it dissapears when the nav bar disappears
// it is created when you call this method
// this is a special view in that it allows touches to it's subviews but passes through touches to itself
@property (nonatomic, strong, readonly) UIView *subview;
@end
