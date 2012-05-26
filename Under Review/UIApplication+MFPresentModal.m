//
//  UIApplication+MFPresentModal.m
//  zabbi
//
//  Created by Jason Gregori on 9/21/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "UIApplication+MFPresentModal.h"

@implementation UIApplication (MFPresentModal)

- (void)mfPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    UIViewController *topMostController = self.windows.count > 0 ? [[self.windows objectAtIndex:0] rootViewController] : nil;
    BOOL done = NO;
    while (!done) {
        if ([topMostController isKindOfClass:[UITabBarController class]]) {
            topMostController = [(UITabBarController *)topMostController selectedViewController];
        }
        else if ([topMostController isKindOfClass:[UINavigationController class]]) {
            topMostController = [(UINavigationController *)topMostController visibleViewController];
        }
        else if (topMostController.modalViewController) {
            topMostController = topMostController.modalViewController;
        }
        else {
            done = YES;
        }
    }
    
    [topMostController presentModalViewController:modalViewController animated:animated];
}

@end
