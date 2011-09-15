//
//  MFViewWithBlockDrawRect.h
//  zabbi
//
//  Created by Jason Gregori on 9/14/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFViewWithBlockDrawRect : UIView
@property (nonatomic, copy) void (^drawRectBlock)(CGRect rect);
@end
