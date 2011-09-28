//
//  MFSmallButtonWithBigTouchZone.h
//  zabbi
//
//  Created by Jason Gregori on 9/27/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: A button that has a hit zone of 44x44 even if it is smaller than that.

/*
 NB: this doesn't not always work, the view where the user touches has to allow touches and be an ancestor of the button.
 */

#import <UIKit/UIKit.h>

@interface MFSmallButtonWithBigTouchZone : UIButton

@end
