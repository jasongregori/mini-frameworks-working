//
//  MFImageViewController.m
//  zabbi
//
//  Created by Jason Gregori on 12/13/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "MFImageViewController.h"

@interface MFImageViewController () <UIScrollViewDelegate> {
    UIActivityIndicatorView *__activityIndicatorView;
    UIImageView *__imageView;
    UIScrollView *__scrollview;
}
- (void)layoutLoadingOrImage;
@end

@interface __MFImageViewController_CenteringScrollView : UIScrollView
@end

@implementation MFImageViewController
@synthesize image = __image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    __image = image;
    if ([self isViewLoaded]) {
        [self layoutLoadingOrImage];
    }
}

- (void)reset {
    if ([self isViewLoaded]) {
        [self layoutLoadingOrImage];
    }
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];

    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    aiv.contentMode = UIViewContentModeCenter;
    aiv.frame = self.view.bounds;
    aiv.hidesWhenStopped = YES;
    [self.view addSubview:aiv];
    __activityIndicatorView = aiv;
    
    UIScrollView *sv = [[__MFImageViewController_CenteringScrollView alloc] initWithFrame:self.view.bounds];
    sv.alwaysBounceHorizontal = YES;
    sv.alwaysBounceVertical = YES;
    sv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    sv.bounces = YES;
    sv.bouncesZoom = YES;
    sv.delegate = self;
    sv.maximumZoomScale = 1;
    sv.showsHorizontalScrollIndicator = NO;
    sv.showsVerticalScrollIndicator = NO;
    [self.view addSubview:sv];
    __scrollview = sv;
    
    UIImageView *iv = [UIImageView new];
    iv.backgroundColor = [UIColor blackColor];
    iv.contentMode = UIViewContentModeCenter;
    iv.opaque = YES;
    [__scrollview addSubview:iv];
    __imageView = iv;
    
    [self layoutLoadingOrImage];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    __activityIndicatorView = nil;
    __scrollview = nil;
    __imageView = nil;
}

- (void)layoutLoadingOrImage {
    if (self.image) {
        [__activityIndicatorView stopAnimating];

        //===== load up image
        // reset zoom
        __scrollview.zoomScale = 1;

        // reset imageview
        __imageView.image = self.image;
        __imageView.frame = (CGRect) { CGPointZero, self.image.size };
        __scrollview.contentSize = self.image.size;
        
        // calculate min/max scale
        CGFloat xScale = __scrollview.bounds.size.width / self.image.size.width;
        CGFloat yScale = __scrollview.bounds.size.height / self.image.size.height;
        CGFloat minScale = MIN(xScale, yScale);
        
        // max scale is 1, adjust for screen resolution
        CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
        
        if (minScale > maxScale) {
            minScale = maxScale;
        }
        
        __scrollview.maximumZoomScale = maxScale;
        __scrollview.minimumZoomScale = minScale;
        __scrollview.zoomScale = minScale;
    }
    else {
        [__activityIndicatorView startAnimating];
        __imageView.image = nil;
    }
}

#pragma mark - UIScrollviewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return __imageView;
}

@end

@implementation __MFImageViewController_CenteringScrollView

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    UIView *view = [self.delegate viewForZoomingInScrollView:self];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = view.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    view.frame = frameToCenter;
}

@end
