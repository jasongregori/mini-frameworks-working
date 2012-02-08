//
//  MFViewParagraph.m
//  zabbi
//
//  Created by Jason Gregori on 1/16/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFViewParagraph.h"

typedef enum {
    kReadyNewSubviews,
    kHideOldViews,
    kRemoveOldViews,
    kLayoutNewViews,
    kShowNewViews
} MFViewParagraphStep;

@interface MFViewParagraph () {
    MFViewParagraphStep _currentStep;
    NSArray *_changeToSubviews;
    NSArray *_oldSubviews;
}
- (void)__MFViewParagraphSharedInit;
- (BOOL)__changeStep:(MFViewParagraphStep)step;
- (CGFloat)__layoutRowOfViews:(NSArray *)rowOfViews forWidth:(CGFloat)width startingYOrigin:(CGFloat)y;
@end

@implementation MFViewParagraph
@synthesize lineSpacing, alignment;

- (void)__MFViewParagraphSharedInit {
    self.autoresizesSubviews = NO;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self __MFViewParagraphSharedInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self __MFViewParagraphSharedInit];
    }
    return self;
}

- (BOOL)__changeStep:(MFViewParagraphStep)step {
    BOOL pass = NO;
    if (step == kReadyNewSubviews) {
        pass = YES;
    }
    else {
        pass = _currentStep == step - 1;
    }
    
    if (pass) {
        _currentStep = step;
        return YES;
    }
    return NO;
}

- (void)readyNewSubviews:(NSArray *)subviews {
    if (![self __changeStep:kReadyNewSubviews]) {
        return;
    }

    _changeToSubviews = subviews;

    NSArray *newSubviews = [subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (%@ CONTAINS self)", self.subviews]];
    
    // add but hide new views
    [newSubviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setAlpha:0];
        [self addSubview:obj];
    }];
    
    _oldSubviews = [self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (%@ CONTAINS self)", subviews]];
}

- (void)hideOldViews {
    if (![self __changeStep:kHideOldViews]) {
        return;
    }
    
    [_oldSubviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setAlpha:0];
    }];
}

- (void)removeOldViews {
    if (![self __changeStep:kRemoveOldViews]) {
        return;
    }
    
    [_oldSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _oldSubviews = nil;
}

// returns the height of this row
- (CGFloat)__layoutRowOfViews:(NSArray *)rowOfViews forWidth:(CGFloat)width startingYOrigin:(CGFloat)y {
    CGFloat height = 0;
    CGFloat viewsTotalWidth = 0;
    
    // get the max height
    for (UIView *view in rowOfViews) {
        if (view.frame.size.height > height) {
            height = view.frame.size.height;
        }
        viewsTotalWidth += view.frame.size.width;
    }

    CGFloat x;
    switch (self.alignment) {
        case UITextAlignmentCenter:
            x = floor((width - viewsTotalWidth)/2.0);
            break;
        case UITextAlignmentRight:
            x = floor((width - viewsTotalWidth));
            break;
        case UITextAlignmentLeft:
        default:
            x = 0;
            break;
    }
    
    // layout the row
    for (UIView *view in rowOfViews) {
        CGRect frame = view.frame;
        frame.origin.x = x;
        x += frame.size.width;
        frame.origin.y = y + floor((height - frame.size.height)/2.0);
        view.frame = frame;
    }
    
    return height > 0 ? height + self.lineSpacing : 0;
}

- (CGFloat)layoutNewViews:(CGFloat)maxWidth {
    if (![self __changeStep:kLayoutNewViews]) {
        return 0;
    }
    
    CGFloat y = 0;
    
    NSMutableArray *rowOfViews = [NSMutableArray array];
    CGFloat rowWidth = 0;
    
    NSUInteger i, count = [_changeToSubviews count];
    for (i = 0; i < count; i++) {
        UIView *view = [_changeToSubviews objectAtIndex:i];
        if (rowWidth + view.frame.size.width > maxWidth) {
            y += [self __layoutRowOfViews:rowOfViews forWidth:maxWidth startingYOrigin:y];
            rowWidth = 0;
            [rowOfViews removeAllObjects];
        }
        [rowOfViews addObject:view];
        rowWidth += view.frame.size.width;
    }
    y += [self __layoutRowOfViews:rowOfViews forWidth:maxWidth startingYOrigin:y];
    
    if (y > self.lineSpacing) {
        y -= self.lineSpacing;
    }
        
    return y;
}

- (void)showNewViews {
    if (![self __changeStep:kShowNewViews]) {
        return;
    }
    
    [_changeToSubviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setAlpha:1];
    }];
    
    _changeToSubviews = nil;
}

- (void)resetWithNewSubviews:(NSArray *)subviews andSizeToFit:(CGFloat)width {
    [self readyNewSubviews:subviews];
    [self hideOldViews];
    [self removeOldViews];
    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = [self layoutNewViews:width];
    self.frame = frame;
    [self showNewViews];
}

@end
