//
//  MFTouchDownGestureRecognizer.h
//  zabbi
//
//  Created by Jason Gregori on 11/7/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

// @mf: a gesture recognizer that recognizes any touch

/*
 
 The idea of MFTouchDownGestureRecognizer is to get call it's targets without affecting any other touches or views.
 I use this to cancel something in the foreground while still allowing the user to touch the background objects.
 
 */

#import <UIKit/UIKit.h>

@interface MFTouchDownGestureRecognizer : UIGestureRecognizer

@end
