//
//  MFViewParagraph.h
//  zabbi
//
//  Created by Jason Gregori on 1/16/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

// @mf: a view that will layout subviews like words in a paragraph

/*
 
 NB: Do not mess with MFViewParagraph's subviews. Use it's methods to change it's subviews.
 
 You may animate these steps which looks awesome :)
 
 */

#import <UIKit/UIKit.h>

@interface MFViewParagraph : UIView
@property (nonatomic, assign) NSUInteger lineSpacing; // space between lines
@property (nonatomic, assign) UITextAlignment alignment;

// These steps must be made in order, you may not skip.
- (void)readyNewSubviews:(NSArray *)subviews;
- (void)hideOldViews;
- (void)removeOldViews;
- (CGFloat)layoutNewViews:(CGFloat)maxWidth; // returns the height required to fit all these views
- (void)showNewViews;

@end
