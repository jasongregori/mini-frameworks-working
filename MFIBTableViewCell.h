//
//  MFIBTableViewCell.h
//  zabbi
//
//  Created by Jason Gregori on 7/14/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

// @MF: Use this tableViewCell class to create cells in Interface Builder

/*
 
 1. Subclass MFIBTableViewCell 
 2. Create a xib file with the same name as the class
 3. Make the first object in the xib an instance of your cell class
 
 */

#import <UIKit/UIKit.h>

@interface MFIBTableViewCell : UITableViewCell

// you must instantiate cells using this method!
// you may subclass +cell to set defaults you weren't able to do in IB
+ (id)cell;
+ (NSString *)reuseIdentifier;
+ (CGFloat)rowHeight;

@end
