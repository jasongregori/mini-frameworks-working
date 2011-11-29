//
//  MFSegmentedViewController.h
//  topics
//
//  Created by Jason Gregori on 5/13/11.
//  Copyright 2011 zabbi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 MFSegmentedViewController shows a segmented control in the nav's title view which it uses to select which view to show.
 
 During init, pass in names and view blocks. View blocks are simple blocks that create a new view to show for that name.
 View blocks are called when it's corresponding index is selected and their view is not loaded.
 View blocks may be called again if a view was gotten rid of due to memory pressure.
 
 Notes
 
 • You may add other views to the main view if you like
 
 */

typedef UIView * (^MFViewBlock)(id segmentedViewController);

typedef enum {
    kMFSegmentedNavigationTitleViewControl,
    kMFSegmentedNavigationControlAtTopOfView,
    kMFSegmentedNoControl,
} MFSegmentedControlStyle;

@interface MFSegmentedViewController : UIViewController

// pass a nil terminated list of names and view blocks
//- (id)initWithNamesAndViewBlocks:(NSString *)firstName, (MFViewBlock)firstViewBlock, ...;
- (id)initWithNamesAndViewBlocks:(NSString *)firstName, ...
    NS_REQUIRES_NIL_TERMINATION;
// designated initializer
- (id)initWithNamesAndViewBlocksArray:(NSArray *)namesAndViewBlocks;

@property (nonatomic, assign) UIBarStyle barStyle;
// This is where the segmented control will be
// Defaults to kMFSegmentedNavigationTitleViewControl
@property (nonatomic, assign) MFSegmentedControlStyle controlStyle;
// Needs to be reset on loadView or viewDidLoad
- (void)setBackgroundView:(UIView *)backgroundView;

// these are returned in the order they are shown in the segmented control
@property (nonatomic, strong, readonly) NSArray *names;

// the views go in this view, don't mess with it.
@property (nonatomic, strong, readonly) UIView *viewsContainer;
@property (nonatomic, assign) NSUInteger selectedIndex;
// views aren't loaded until they are needed
// returns NSNotFound returned if not found
- (NSUInteger)indexForLoadedSubView:(UIView *)view;
- (id)loadedSubViewForIndex:(NSUInteger)index;
- (id)loadSubViewForIndex:(NSUInteger)index;
- (NSSet *)loadedSubViews;

// called after a view is loaded. default implementation does nothing.
- (void)subViewDidLoad:(UIView *)view atIndex:(NSUInteger)index;
// called after a view is shown (either by the SegVC being shown or the user selected another view)
- (void)subViewWillAppear:(UIView *)view atIndex:(NSUInteger)index;
- (void)subViewDidAppear:(UIView *)view atIndex:(NSUInteger)index;

@end

