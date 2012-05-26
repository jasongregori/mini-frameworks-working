//
//  MFSegmentedTableViewController.m
//  topics
//
//  Created by Jason Gregori on 6/3/11.
//  Copyright 2011 zabbi, Inc. All rights reserved.
//

#import "MFSegmentedTableViewController.h"

@implementation MFSegmentedTableViewController
@synthesize clearsSelectionOnSubViewWillAppear;

- (id)initWithNamesAndViewBlocksArray:(NSArray *)namesAndViewBlocks {
    self = [super initWithNamesAndViewBlocksArray:namesAndViewBlocks];
    if (self) {
        self.clearsSelectionOnSubViewWillAppear = YES;
    }
    return self;
}

- (void)subViewWillAppear:(UIView *)view atIndex:(NSUInteger)index {
    if (self.clearsSelectionOnSubViewWillAppear) {
        if ([view isKindOfClass:[UITableView class]]) {
            [(UITableView *)view deselectRowAtIndexPath:[(UITableView *)view indexPathForSelectedRow] animated:YES];
        }
    }
}

@end
