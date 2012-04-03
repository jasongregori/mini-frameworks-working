//
//  UILocalizedIndexedCollation+MFSorting.m
//  zabbi
//
//  Created by Jason Gregori on 4/2/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "UILocalizedIndexedCollation+MFSorting.h"

@implementation UILocalizedIndexedCollation (MFSorting)

- (NSMutableArray *)mfSectionsFilledWithItems:(NSArray *)items sortedByCollationStringSelector:(SEL)sortSelector {
    NSInteger sectionTitlesCount = [[self sectionTitles] count];
    NSMutableArray *sections = [NSMutableArray array];
    
    // create an array for every section
    for (NSInteger i = 0; i < sectionTitlesCount; i++) {
        [sections addObject:[NSMutableArray array]];
    }
    
    // add items to arrays
    for (NSDictionary *item in items) {
        NSInteger section = [self sectionForObject:item collationStringSelector:sortSelector];
        [[sections objectAtIndex:section] addObject:item];
    }
    
    // sort items
    for (NSInteger i = 0; i < sectionTitlesCount; i++) {
        NSMutableDictionary *newSection = [[self sortedArrayFromArray:[sections objectAtIndex:i]
                                              collationStringSelector:sortSelector]
                                           mutableCopy];
        [sections replaceObjectAtIndex:i withObject:newSection];
    }
    
    return sections;
}

@end
