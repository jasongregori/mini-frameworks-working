//
//  MPMediaPickerController+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 10/14/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface MPMediaPickerController (MFBlockize)
+ (id)mfAnotherWithDidPickBlock:(void (^)(MPMediaPickerController *controller, MPMediaItemCollection *collection))didPickBlock
                    cancelBlock:(void (^)(MPMediaPickerController *controller))cancelBlock;
+ (id)mfAnotherWithMediaTypes:(MPMediaType)mediaTypes
                 didPickBlock:(void (^)(MPMediaPickerController *controller, MPMediaItemCollection *collection))didPickBlock
                  cancelBlock:(void (^)(MPMediaPickerController *controller))cancelBlock;
- (void)mfSetDidPickBlock:(void (^)(MPMediaPickerController *controller, MPMediaItemCollection *collection))didPickBlock
           andCancelBlock:(void (^)(MPMediaPickerController *controller))cancelBlock;
@end
