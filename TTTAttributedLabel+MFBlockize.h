//
//  TTTAttributedLabel+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 4/17/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "TTTAttributedLabel.h"

@interface TTTAttributedLabel (MFBlockize)
// setting this block sets the label's delegate. if you change the delegate after, your block will not be called.
// setting this to nil clears out the block and delegate.
- (void)mfSetDidSelectLinkWithTextCheckingResultBlock:(void (^)(NSTextCheckingResult *result))block;
@end
