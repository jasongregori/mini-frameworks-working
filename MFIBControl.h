//
//  MFIBControl.h
//  zabbi
//
//  Created by Jason Gregori on 11/7/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

// @mf: subclass this UIControl to create UIControls in IB

/*
 
 1. Subclass MFIBControl
 2. Create a xib file with the same name as the class
 3. Make the first object in the xib an instance of your control class
 
 MFIBControl works by replacing self when initWithFrame is called so you can use the usual init methods.
 NB: You cannot put an MFIBControl into another IB (yet)
 
 */

#import <UIKit/UIKit.h>

@interface MFIBControl : UIControl

// you may subclass +mfControl to set defaults you weren't able to do in IB
// you may also set defaults in `initWithCoder:` but subviews you add in IB won't be connected yet.
+ (id)mfControl;

@end
