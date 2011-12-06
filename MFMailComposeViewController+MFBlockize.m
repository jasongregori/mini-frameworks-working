//
//  MFMailComposeViewController+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 12/5/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "MFMailComposeViewController+MFBlockize.h"

#import <objc/runtime.h>

@interface __MFMailComposeViewController_MFBlockize_Helper : NSObject <MFMailComposeViewControllerDelegate>
@property (nonatomic, copy) void (^block)(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error);
@end

@implementation MFMailComposeViewController (MFBlockize)

- (void)mfSetBlockDelegate:(void (^)(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error))block {
    // create delegate
    __MFMailComposeViewController_MFBlockize_Helper *helper = [__MFMailComposeViewController_MFBlockize_Helper new];
    helper.block = block;

    // set delegate
    self.mailComposeDelegate = helper;

    // save delegate as associated object
    static char associationKey;
    objc_setAssociatedObject(self, &associationKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation __MFMailComposeViewController_MFBlockize_Helper
@synthesize block;

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (self.block) {
        self.block(controller, result, error);
    }
    else {
        [controller dismissModalViewControllerAnimated:YES];
    }
}

@end