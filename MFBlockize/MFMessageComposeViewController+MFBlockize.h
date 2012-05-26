//
//  MFMessageComposeViewController+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 12/26/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface MFMessageComposeViewController (MFBlockize)

- (void)mfSetBlockDelegate:(void (^)(MFMessageComposeViewController *controller, MessageComposeResult result))block;

@end
