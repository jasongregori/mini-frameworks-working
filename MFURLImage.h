//
//  MFURLImage.h
//  zabbi
//
//  Created by Jason Gregori on 7/22/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSURLConnection+MFBlockize.h"

@interface MFURLImageView : UIImageView
@property (nonatomic, copy) NSString *url;
@end
