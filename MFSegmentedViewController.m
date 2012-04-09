//
//  MFSegmentedViewController.m
//  topics
//
//  Created by Jason Gregori on 5/13/11.
//  Copyright 2011 zabbi, Inc. All rights reserved.
//

#import "MFSegmentedViewController.h"

#define kSegmentedControlMargin 6
#define kSegmentedControlWidth (320 - 2 * kSegmentedControlMargin)

@interface MFSegmentedViewController () {
    UIToolbar *_toolbar;
}
@property (nonatomic, strong, readwrite) NSArray *namesOrImages;
@property (nonatomic, strong) NSMutableDictionary *__loadedSubViews;
@property (nonatomic, strong) UISegmentedControl *__segmentedControl;
@property (nonatomic, strong) NSArray *__viewBlocks;
@property (nonatomic, strong) UIView *viewsContainer;

- (void)__layoutSelectedIndex;
- (void)__segmentedControlValueChanged;
- (void)__layoutViewsContainer;
@end

@implementation MFSegmentedViewController
@synthesize namesOrImages = _namesOrImages, __loadedSubViews, __viewBlocks, controlStyle;
@synthesize barStyle;
@synthesize headerView = _headerView;

- (id)initWithNamesAndViewBlocks:(id)firstNameOrImage, ...
{
    NSMutableArray *namesAndViewBlocksArray = [NSMutableArray array];
    va_list args;
    va_start(args, firstNameOrImage);
    for (id arg = firstNameOrImage; arg != nil; arg = va_arg(args, id))
    {
        [namesAndViewBlocksArray addObject:arg];
    }
    va_end(args);
    
    return [self initWithNamesAndViewBlocksArray:namesAndViewBlocksArray];
}

- (id)initWithNames:(NSArray *)namesOrImages {
    NSMutableArray *namesAndViewBlocksArray = [NSMutableArray array];
    NSUInteger index = 0;
    for (id nameOrImage in namesOrImages) {
        [namesAndViewBlocksArray addObject:nameOrImage];
        [namesAndViewBlocksArray addObject:^UIView *(MFSegmentedViewController *c) {
            return [c loadViewForIndex:index];
        }];
        index++;
    }
    return [self initWithNamesAndViewBlocksArray:namesAndViewBlocksArray];
}

- (id)initWithNamesAndViewBlocksArray:(NSArray *)namesAndViewBlocks
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        NSMutableArray *kys = [NSMutableArray array];
        NSMutableArray *vbs = [NSMutableArray array];
        
        NSUInteger count = [namesAndViewBlocks count];
        for (NSUInteger i = 0; i < count; i+=2) {
            [kys addObject:[namesAndViewBlocks objectAtIndex:i]];
            [vbs addObject:[[namesAndViewBlocks objectAtIndex:i+1] copy]];
        }
        
        self.namesOrImages = kys;
        self.__viewBlocks = vbs;
        self.__loadedSubViews = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    [NSException raise:@"MFSegmentedViewControllerException" format:@"You must use the `initWithKeysAndViewBlocks:` method for initialization"];
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [NSException raise:@"MFSegmentedViewControllerException" format:@"You must use the `initWithKeysAndViewBlocks:` method for initialization"];
    return nil;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any views that aren't being used
    for (NSNumber *index in [self.__loadedSubViews copy])
    {
        if ([index unsignedIntegerValue] != self.selectedIndex)
        {
            [[self.__loadedSubViews objectForKey:index] removeFromSuperview];
            [self.__loadedSubViews removeObjectForKey:index];
        }
    }
}

#pragma mark - Public
@synthesize selectedIndex;

- (UIView *)selectedLoadedView {
    return [self loadedSubViewForIndex:self.selectedIndex];
}

- (UIView *)loadViewForIndex:(NSUInteger)index {
    [NSException raise:@"MFSegmentedViewControllerException" format:@"If you don't pass in view blocks, you must override -loadViewForIndex:"];
    return nil;
}

- (NSUInteger)indexForLoadedSubView:(UIView *)view
{
    NSNumber *index = [[self.__loadedSubViews allKeysForObject:view] lastObject];
    if (index) {
        return [index unsignedIntegerValue];
    }
    return NSNotFound;
}

- (id)loadedSubViewForIndex:(NSUInteger)index
{
    return [self.__loadedSubViews objectForKey:[NSNumber numberWithUnsignedInteger:index]];
}

- (id)loadSubViewForIndex:(NSUInteger)index {
    // see if already loaded
    UIView *view = [self loadedSubViewForIndex:self.selectedIndex];
    // load if not already loaded
    if (!view)
    {
        MFViewBlock viewBlock = [self.__viewBlocks objectAtIndex:self.selectedIndex];
        view = viewBlock(self);
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.__loadedSubViews setObject:view forKey:[NSNumber numberWithInteger:self.selectedIndex]];
        [self subViewDidLoad:view atIndex:self.selectedIndex];
    }
    return view;
}

- (NSSet *)loadedSubViews
{
    return [NSSet setWithArray:[self.__loadedSubViews allValues]];
}

- (void)setBackgroundView:(UIView *)backgroundView {
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.frame = self.viewsContainer.frame;
    [self.view insertSubview:backgroundView atIndex:0];
}

- (void)setSelectedIndex:(NSUInteger)i
{
    if (selectedIndex != i)
    {
        NSUInteger oldSelectedIndex = selectedIndex;
        selectedIndex = i;
        if ([self isViewLoaded])
        {
            // set segmented control
            self.__segmentedControl.selectedSegmentIndex = i;
            // remove current view (if applicable)
            UIView *oldSelectedView = [self loadedSubViewForIndex:oldSelectedIndex];
            if (oldSelectedView) {
                [self subViewWillBeDeselected:oldSelectedView atIndex:oldSelectedIndex];
                [oldSelectedView removeFromSuperview];
            }
            
            [self __layoutSelectedIndex];
        }
    }
}

- (void)subViewDidLoad:(UIView *)view atIndex:(NSUInteger)index {
    
}

- (void)subViewDidAppear:(UIView *)view atIndex:(NSUInteger)index {
    // if current view is a scrollview, flash scrollers
    if ([view isKindOfClass:[UIScrollView class]]) {
        [(UIScrollView *)view flashScrollIndicators];
    }
}

- (void)subViewWillAppear:(UIView *)view atIndex:(NSUInteger)index {
    
}

- (void)subViewWillBeDeselected:(UIView *)view atIndex:(NSUInteger)index {
    
}

- (void)subViewWillBeSelected:(UIView *)view atIndex:(NSUInteger)index {

}

- (void)setHeaderView:(UIView *)headerView {
    if (headerView != _headerView) {
        [_headerView removeFromSuperview];
        _headerView = headerView;
        
        if ([self isViewLoaded]) {
            [self __layoutViewsContainer];
        }
    }
}

- (void)__layoutViewsContainer {
    CGFloat topSpace = _toolbar.frame.size.height;
    
    if (self.headerView) {
        CGRect frame = self.headerView.frame;
        frame.origin.y = topSpace;
        self.headerView.frame = frame;
        
        [self.view addSubview:self.headerView];
        
        topSpace += self.headerView.frame.size.height;
    }
    
    self.viewsContainer.frame = CGRectMake(0, topSpace, self.view.bounds.size.width, self.view.bounds.size.height - topSpace);
}

#pragma mark - View lifecycle
@synthesize __segmentedControl, viewsContainer = __viewsContainer;

- (void)__layoutSelectedIndex
{
    UIView *view = [self loadSubViewForIndex:self.selectedIndex];
    view.frame = self.viewsContainer.bounds;        
    // show
    [self subViewWillAppear:view atIndex:self.selectedIndex];
    [self subViewWillBeSelected:view atIndex:self.selectedIndex];
    [self.viewsContainer addSubview:view];
}

- (void)__segmentedControlValueChanged
{
    self.selectedIndex = self.__segmentedControl.selectedSegmentIndex;
    
    [self subViewDidAppear:[self loadedSubViewForIndex:self.selectedIndex] atIndex:self.selectedIndex];
}

- (void)loadView
{
    [super loadView];

    CGFloat containerTop = 0;
    
    if (self.controlStyle != kMFSegmentedNoControl) {
        UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:self.namesOrImages];
        sc.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        sc.segmentedControlStyle = UISegmentedControlStyleBar;
        sc.selectedSegmentIndex = self.selectedIndex;
        sc.frame = CGRectMake(kSegmentedControlMargin, 0, kSegmentedControlWidth, [sc sizeThatFits:CGSizeZero].height);
        [sc addTarget:self action:@selector(__segmentedControlValueChanged) forControlEvents:UIControlEventValueChanged];
        self.__segmentedControl = sc;
        if (self.controlStyle == kMFSegmentedNavigationTitleViewControl) {
            self.navigationItem.titleView = sc;
        }
        else {
            UIToolbar *toolbar = [[UIToolbar alloc] init];
            toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            toolbar.barStyle = self.barStyle;
            containerTop = [toolbar sizeThatFits:CGSizeZero].height;
            toolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, containerTop);
            toolbar.items = [NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithCustomView:sc]];
            [self.view addSubview:toolbar];
            _toolbar = toolbar;
        }
    }
    
    UIView *container = [UIView new];
    container.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.viewsContainer = container;
    [self __layoutViewsContainer];
    [self.view addSubview:container];
    
    [self __layoutSelectedIndex];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if (self.navigationItem.titleView == self.__segmentedControl) {
        self.navigationItem.titleView = nil;
    }
    self.__segmentedControl = nil;
    self.viewsContainer = nil;
    [self subViewWillBeDeselected:[self loadedSubViewForIndex:self.selectedIndex] atIndex:self.selectedIndex];
    [self.__loadedSubViews removeAllObjects];
    _toolbar = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar layoutSubviews];
    [self subViewWillAppear:[self loadedSubViewForIndex:self.selectedIndex] atIndex:self.selectedIndex];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self subViewDidAppear:[self loadedSubViewForIndex:self.selectedIndex] atIndex:self.selectedIndex];
}

@end
