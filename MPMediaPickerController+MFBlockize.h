//
//  MPMediaPickerController+MFBlockize.h
//  zabbi
//
//  Created by Jason Gregori on 10/14/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface MPMediaPickerController (MFBlockize)
+ (id)mfAnotherWithDidPickBlock:(void (^)(MPMediaItemCollection *collection))didPickBlock
                    cancelBlock:(void (^)())cancelBlock;
+ (id)mfAnotherWithMediaTypes:(MPMediaType)mediaTypes
                 didPickBlock:(void (^)(MPMediaItemCollection *collection))didPickBlock
                  cancelBlock:(void (^)())cancelBlock;
@end
