//
//  UIApplication+MFPresentModal.h
//  zabbi
//
//  Created by Jason Gregori on 9/21/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: Allows you to present a modal over *all* the view controllers in your app. 

#import <UIKit/UIKit.h>

@interface UIApplication (MFPresentModal)

- (void)mfPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;

@end
