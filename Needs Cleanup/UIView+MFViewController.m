//
//  UIView+MFViewController.m
//  zabbi
//
//  Created by Jason Gregori on 10/10/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "UIView+MFViewController.h"

@implementation UIView (MFViewController)

- (UIViewController *)mfViewController {
    UIResponder *responder = self;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    return (UIViewController *)responder;
}

@end
