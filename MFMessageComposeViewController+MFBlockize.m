//
//  MFMessageComposeViewController+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 12/26/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "MFMessageComposeViewController+MFBlockize.h"

#import <objc/runtime.h>

@interface __MFMessageComposeViewController_MFBlockize_Helper : NSObject <MFMessageComposeViewControllerDelegate>
@property (nonatomic, copy) void (^block)(MFMessageComposeViewController *controller, MessageComposeResult result);
@end

@implementation MFMessageComposeViewController (MFBlockize)

- (void)mfSetBlockDelegate:(void (^)(MFMessageComposeViewController *controller, MessageComposeResult result))block {
    __MFMessageComposeViewController_MFBlockize_Helper *helper = [__MFMessageComposeViewController_MFBlockize_Helper new];
    helper.block = block;
    
    // set delegate
    self.messageComposeDelegate = helper;
    
    // save delegate as associated object
    static char associationKey;
    objc_setAssociatedObject(self, &associationKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation __MFMessageComposeViewController_MFBlockize_Helper
@synthesize block;

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (self.block) {
        self.block(controller, result);
    }
    else {
        [controller dismissModalViewControllerAnimated:YES];
    }
}

@end