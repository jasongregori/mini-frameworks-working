//
//  MFButtonThatsVeryCustomizable.h
//  zabbi
//
//  Created by Jason Gregori on 10/10/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFButtonThatsVeryCustomizable : UIButton

- (void)setCustomizationBlock:(void (^)(MFButtonThatsVeryCustomizable *button))block
                     forState:(UIControlState)state;
- (void)mfLayoutCustomizations;

@end
