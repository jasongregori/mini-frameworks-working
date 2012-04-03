//
//  UILocalizedIndexedCollation+MFSorting.h
//  zabbi
//
//  Created by Jason Gregori on 4/2/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILocalizedIndexedCollation (MFSorting)

// returns a mutable array of sections filled with mutable arrays of items
- (NSMutableArray *)mfSectionsFilledWithItems:(NSArray *)items sortedByCollationStringSelector:(SEL)sortSelector;

@end
