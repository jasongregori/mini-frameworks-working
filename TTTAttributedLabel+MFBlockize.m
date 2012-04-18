//
//  TTTAttributedLabel+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 4/17/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "TTTAttributedLabel+MFBlockize.h"

#import <objc/runtime.h>

@interface __TTTAttributedLabel_MFBlockize_Helper : NSObject <TTTAttributedLabelDelegate>
@property (nonatomic, copy) void (^didSelectLinkWithTextCheckingResultBlock)(NSTextCheckingResult *result);
@end

@implementation TTTAttributedLabel (MFBlockize)

- (void)mfSetDidSelectLinkWithTextCheckingResultBlock:(void (^)(NSTextCheckingResult *result))block {
    
    __TTTAttributedLabel_MFBlockize_Helper *helper;
    
    if (block) {
        // create helper
        helper = [__TTTAttributedLabel_MFBlockize_Helper new];
        helper.didSelectLinkWithTextCheckingResultBlock = block;
    }
    
    self.delegate = helper;
    
    // retain the helper
    static char helperKey;
    objc_setAssociatedObject(self, &helperKey, helper, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation __TTTAttributedLabel_MFBlockize_Helper
@synthesize didSelectLinkWithTextCheckingResultBlock;

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    if (self.didSelectLinkWithTextCheckingResultBlock) {
        self.didSelectLinkWithTextCheckingResultBlock(result);
    }
}

@end