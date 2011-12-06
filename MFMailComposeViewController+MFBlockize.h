//
//  MFMailComposeViewController+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 12/5/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface MFMailComposeViewController (MFBlockize)

- (void)mfSetBlockDelegate:(void (^)(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error))block;

@end
