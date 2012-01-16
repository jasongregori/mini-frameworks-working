//
//  MFViewParagraph.m
//  zabbi
//
//  Created by Jason Gregori on 1/16/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFViewParagraph.h"

typedef enum {
    kStartStep,
    kReadyNewSubviews,
    kHideOldViews,
    kRemoveOldViews,
    kLayoutNewViews,
    kShowNewViews
} MFViewParagraphStep;

@interface MFViewParagraph () {
    MFViewParagraphStep _currentStep;
    NSArray *_oldSubviews;
}
- (void)__MFViewParagraphSharedInit;
- (void)__changeStep:(MFViewParagraphStep)step;
- (CGFloat)__layoutRowOfViews:(NSArray *)rowOfViews forWidth:(CGFloat)width;
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

- (void)__changeStep:(MFViewParagraphStep)step {
    BOOL pass = NO;
    if (step == kStartStep) {
        pass = _currentStep == kShowNewViews;
    }
    else {
        pass = _currentStep == step - 1;
    }
    
    if (pass) {
        _currentStep = step;
    }
    else {
        [NSException raise:@"MFViewParagraphStepException"
                    format:@"You skipped a step!"];
    }
}

- (void)readyNewSubviews:(NSArray *)subviews {
    [self __changeStep:kReadyNewSubviews];
    
    NSArray *newSubviews = [subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (%@ CONTAINS self)", self.subviews]];
    
    // add but hide new views
    [newSubviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setAlpha:0];
        [self addSubview:obj];
    }];
    
    _oldSubviews = [self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (%@ CONTAINS self)", subviews]];
}

- (void)hideOldViews {
    [self __changeStep:kHideOldViews];
    
    [_oldSubviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setAlpha:0];
    }];
}

- (void)removeOldViews {
    [self __changeStep:kRemoveOldViews];
    
    [_oldSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _oldSubviews = nil;
}

// returns the height of this row
- (CGFloat)__layoutRowOfViews:(NSArray *)rowOfViews forWidth:(CGFloat)width {
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
        frame.origin.y = floor((height - frame.size.height)/2.0);
        view.frame = frame;
    }
    
    return height > 0 ? height + self.lineSpacing : 0;
}

- (CGFloat)layoutNewViews:(CGFloat)maxWidth {
    [self __changeStep:kLayoutNewViews];
    
    CGFloat y = 0;
    
    NSMutableArray *rowOfViews = [NSMutableArray array];
    CGFloat rowWidth = 0;
    
    NSUInteger i, count = [self.subviews count];
    for (i = 0; i < count; i++) {
        UIView *view = [self.subviews objectAtIndex:i];
        if (rowWidth + view.bounds.size.width > maxWidth) {
            y += [self __layoutRowOfViews:rowOfViews forWidth:maxWidth];
            rowWidth = 0;
            [rowOfViews removeAllObjects];
        }
        [rowOfViews addObject:view];
    }
    y += [self __layoutRowOfViews:rowOfViews forWidth:maxWidth];
        
    return y;
}

- (void)showNewViews {
    [self __changeStep:kShowNewViews];
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setAlpha:1];
    }];
    
    [self __changeStep:kStartStep];
}

@end
