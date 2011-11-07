//
//  MFTouchDownGestureRecognizer.h
//  zabbi
//
//  Created by Jason Gregori on 11/7/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

// @mf: a gesture recognizer that recognizes any touch

/*
 
 • The idea of MFTouchDownGestureRecognizer is to call it's targets without affecting any other touches or views.
 • I use this to cancel something in the foreground while still allowing the user to touch the background objects.
 • Note: if you use it like that you should put it in a view that is not a parent of the foreground view but is a parent of the background view (or is the background view)
   otherwise it gets called when the user touches the foreground view as well
 
 */

#import <UIKit/UIKit.h>

@interface MFTouchDownGestureRecognizer : UIGestureRecognizer

@end
