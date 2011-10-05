//
//  MFIBView.h
//  zabbi
//
//  Created by Jason Gregori on 10/5/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @mf: subclass this view to create views in IB

/*
 
 1. Subclass MFIBView
 2. Create a xib file with the same name as the class
 3. Make the first object in the xib an instance of your cell class
 
 MFIBView works by replacing self when initWithFrame is called so you can use the usual init methods.
 NB: You cannot put an MFIBView into another IB (yet)
 
 */

#import <UIKit/UIKit.h>

@interface MFIBView : UIView

// you may subclass +mfView to set defaults you weren't able to do in IB
// you may also set defaults in `initWithCoder:` but subviews you add in IB won't be connected yet.
+ (id)mfView;

@end
