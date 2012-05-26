//
//  MFPaddedLabel.h
//  zabbi
//
//  Created by Jason Gregori on 9/21/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @MF: A UILabel that has padding in it

#import <UIKit/UIKit.h>

@interface MFPaddedLabel : UILabel
// defaults to 0,3,0,3
@property (nonatomic, assign) UIEdgeInsets mfPadding;
@end
