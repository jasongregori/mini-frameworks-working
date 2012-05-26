//
//  MFSegmentedTableViewController.h
//  topics
//
//  Created by Jason Gregori on 6/3/11.
//  Copyright 2011 zabbi, Inc. All rights reserved.
//

// @MF: MFSegmentedTableViewController is just a SegmentedViewController that does UITableViewController stuff for tableViews

#import <UIKit/UIKit.h>
#import "MFSegmentedViewController.h"

@interface MFSegmentedTableViewController : MFSegmentedViewController
@property (nonatomic, assign) BOOL clearsSelectionOnSubViewWillAppear;
@end
