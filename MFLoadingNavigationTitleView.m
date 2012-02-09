//
//  ZALoadingNavigationTitleView.m
//  zabbi
//
//  Created by Jason Gregori on 7/29/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFLoadingNavigationTitleView.h"

@implementation MFLoadingNavigationTitleView

+ (id)loadingTitleView:(NSString *)title {
    CGFloat height = 44;
    CGFloat verticalCenteringOffset = -2;
    
    UIActivityIndicatorView *aiv = [UIActivityIndicatorView mfAnotherWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite animating:YES];
    aiv.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                            | UIViewAutoresizingFlexibleRightMargin
                            | UIViewAutoresizingFlexibleBottomMargin);
    aiv.frame = (CGRect){CGPointMake(0, ceil((height - aiv.bounds.size.height)/2.0)+verticalCenteringOffset), aiv.bounds.size};
    
    CGFloat spaceBetween = 8;
    
    UILabel *label = [UILabel mfAnother];
    label.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                              | UIViewAutoresizingFlexibleWidth
                              | UIViewAutoresizingFlexibleBottomMargin);
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.minimumFontSize = 10;
    label.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    label.shadowOffset = CGSizeMake(0, -1);
    label.text = title;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.frame = (CGRect){CGPointMake(aiv.bounds.size.width + spaceBetween, ceil((height - label.bounds.size.height)/2.0)+verticalCenteringOffset), label.bounds.size};
    
    // ## put the same amount of space on either side of the label so it is centered
    UIView *view = [UIView mfAnotherWithFrame:CGRectMake(0, 0, (aiv.bounds.size.width + spaceBetween) * 2 + label.bounds.size.width, height)];
    [view addSubview:aiv];
    [view addSubview:label];
    return view;
}

@end
