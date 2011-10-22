//
//  UIImagePickerController+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 10/21/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImagePickerController

+ (id)mfAnotherWithDidFinishPickingBlock:(void (^)(NSDictionary *mediaInfo))didPickBlock
                             cancelBlock:(void (^)())cancelBlock;

@end
