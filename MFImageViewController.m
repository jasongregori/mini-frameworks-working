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
    
    // rotation
    CGPoint __rotationRestorePoint;
    CGFloat __rotationRestoreScale;
    UIInterfaceOrientation __lastOrientation;
}
// status bar and navigation bar
@property (nonatomic, copy) void (^__statusBarAndNaviationBarResetBlock)();

- (void)__attemptRotation;
- (void)__layoutLoadingOrImage;
- (void)__scrollviewDoubleTapped:(UITapGestureRecognizer *)gestureRecognizer;
- (void)__setMaxMinZoomScale;
@end

@interface __MFImageViewController_CenteringScrollView : UIScrollView
@end

@implementation MFImageViewController
@synthesize image = __image;
@synthesize __statusBarAndNaviationBarResetBlock;

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
        [self __layoutLoadingOrImage];
    }
}

- (void)reset {
    if ([self isViewLoaded]) {
        [self __layoutLoadingOrImage];
    }
}

#pragma mark -

- (void)__attemptRotation {
    if ([[UIViewController class] respondsToSelector:@selector(attemptRotationToDeviceOrientation)]
        && !__scrollview.dragging
        && !__scrollview.zooming
        && !__scrollview.decelerating) {
        [UIViewController attemptRotationToDeviceOrientation];
    }
}

- (void)__setMaxMinZoomScale {
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
}

- (void)__layoutLoadingOrImage {
    if (self.image) {
        [__activityIndicatorView stopAnimating];
        
        //===== load up image
        // reset zoom
        __scrollview.zoomScale = 1;
        
        // reset imageview
        __imageView.image = self.image;
        __imageView.bounds = (CGRect) { CGPointZero, self.image.size };
        __scrollview.contentSize = self.image.size;

        [self __setMaxMinZoomScale];
        
        __scrollview.zoomScale = __scrollview.minimumZoomScale;
    }
    else {
        [__activityIndicatorView startAnimating];
        __imageView.image = nil;
    }
}

- (void)__scrollviewDoubleTapped:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (__scrollview.zoomScale < (__scrollview.maximumZoomScale + __scrollview.minimumZoomScale)/2.0) {
            [__scrollview zoomToRect:(CGRect){ [gestureRecognizer locationInView:__imageView], CGSizeZero}
                            animated:YES];
        }
        else {
            [__scrollview setZoomScale:__scrollview.minimumZoomScale animated:YES];
        }
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
    sv.decelerationRate = UIScrollViewDecelerationRateFast;
    sv.delegate = self;
    sv.maximumZoomScale = 1;
    sv.showsHorizontalScrollIndicator = NO;
    sv.showsVerticalScrollIndicator = NO;
    [self.view addSubview:sv];
    __scrollview = sv;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__scrollviewDoubleTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [__scrollview addGestureRecognizer:tapGestureRecognizer];
    
    UIImageView *iv = [UIImageView new];
    iv.backgroundColor = [UIColor blackColor];
    iv.contentMode = UIViewContentModeCenter;
    iv.opaque = YES;
    [__scrollview addSubview:iv];
    __imageView = iv;
    
    [self __layoutLoadingOrImage];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    __activityIndicatorView = nil;
    __scrollview = nil;
    __imageView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //===== save status bar and navigation bar style
    UIStatusBarStyle oldStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    UINavigationBar *nb = self.navigationController.navigationBar;
    BOOL oldNavBarTranslucent = nb.translucent;
    UIBarStyle oldNavBarStyle = nb.barStyle;
    UIColor *oldNavBarTint = nb.tintColor;
    BOOL nbCustomImages = [nb respondsToSelector:@selector(backgroundImageForBarMetrics:)];
    UIImage *oldBackgroundImageDefault, *oldBackgroundImageLandscapePhone;
    if (nbCustomImages) {
        oldBackgroundImageDefault = [nb backgroundImageForBarMetrics:UIBarMetricsDefault];
        oldBackgroundImageLandscapePhone = [nb backgroundImageForBarMetrics:UIBarMetricsLandscapePhone];
    }
    self.__statusBarAndNaviationBarResetBlock = ^{
        [[UIApplication sharedApplication] setStatusBarStyle:oldStatusBarStyle animated:YES];
        nb.translucent = oldNavBarTranslucent;
        nb.barStyle = oldNavBarStyle;
        nb.tintColor = oldNavBarTint;
        if (nbCustomImages) {
            [nb setBackgroundImage:oldBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
            [nb setBackgroundImage:oldBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsLandscapePhone];
        }
        
        // animate
        CATransition *a = [CATransition animation];
        [a setDuration:0.2];
        [a setType:kCATransitionFade];
        [a setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[nb layer] addAnimation:a forKey:kCATransitionFade];
    };
    
    //===== change status bar and navigation bar style
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    nb.translucent = YES;
    nb.barStyle = UIBarStyleBlack;
    nb.tintColor = nil;
    if (nbCustomImages) {
        [nb setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [nb setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
    }

    // animate
    CATransition *a = [CATransition animation];
    [a setDuration:0.2];
    [a setType:kCATransitionFade];
    [a setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[nb layer] addAnimation:a forKey:kCATransitionFade];
    
    if (self.interfaceOrientation != __lastOrientation) {
        [self reset];
        __lastOrientation = self.interfaceOrientation;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.__statusBarAndNaviationBarResetBlock) {
        self.__statusBarAndNaviationBarResetBlock();
        self.__statusBarAndNaviationBarResetBlock = nil;
    }
}

#pragma mark - rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (!__scrollview.dragging && !__scrollview.zooming && !__scrollview.decelerating);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    __lastOrientation = toInterfaceOrientation;
    
    // this is the point on the image view that is at the center of the screen
    __rotationRestorePoint = [__scrollview convertPoint:CGPointMake(CGRectGetMidX(__scrollview.bounds), CGRectGetMidY(__scrollview.bounds)) toView:__imageView];

    __rotationRestoreScale = __scrollview.zoomScale;
    // set scale to zero if we are at the minimum (so we know to go to the minimum after rotation)
    if (__rotationRestoreScale <= __scrollview.minimumZoomScale + FLT_EPSILON) {
        __rotationRestoreScale = 0;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self __setMaxMinZoomScale];
    
    __scrollview.zoomScale = MIN(__scrollview.maximumZoomScale, MAX(__rotationRestoreScale, __scrollview.minimumZoomScale));
    
    // this is the point in scrollview that is the point that was the center of the screen before
    CGPoint boundsCenter = [__scrollview convertPoint:__rotationRestorePoint fromView:__imageView];
    // make this point the center now
    CGPoint offset = CGPointMake(boundsCenter.x - __scrollview.bounds.size.width/2.0,
                                 boundsCenter.y - __scrollview.bounds.size.height/2.0);
    offset.x = MAX(0, MIN(offset.x, __scrollview.contentSize.width - __scrollview.bounds.size.width));
    offset.y = MAX(0, MIN(offset.y, __scrollview.contentSize.height - __scrollview.bounds.size.height));
    __scrollview.contentOffset = offset;
}

#pragma mark - UIScrollviewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self __attemptRotation];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self __attemptRotation];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    [self __attemptRotation];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

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
