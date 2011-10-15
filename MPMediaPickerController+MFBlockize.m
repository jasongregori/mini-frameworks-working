//
//  MPMediaPickerController+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 10/14/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "MPMediaPickerController+MFBlockize.h"

#import <objc/runtime.h>

@interface __MPMediaPickerController_MFBlockize_Helper : NSObject <MPMediaPickerControllerDelegate>
@property (nonatomic, copy) void (^didPickBlock)(MPMediaItemCollection *collection);
@property (nonatomic, copy) void (^cancelBlock)();
@end

@implementation MPMediaPickerController (MFBlockize)
+ (id)mfAnotherWithDidPickBlock:(void (^)(MPMediaItemCollection *collection))didPickBlock
                    cancelBlock:(void (^)())cancelBlock {
    return [self mfAnotherWithMediaTypes:MPMediaTypeAny
                            didPickBlock:didPickBlock
                             cancelBlock:cancelBlock];
}
+ (id)mfAnotherWithMediaTypes:(MPMediaType)mediaTypes
                 didPickBlock:(void (^)(MPMediaItemCollection *collection))didPickBlock
                  cancelBlock:(void (^)())cancelBlock {
    __MPMediaPickerController_MFBlockize_Helper *helper = [__MPMediaPickerController_MFBlockize_Helper new];
    helper.didPickBlock = didPickBlock;
    helper.cancelBlock = cancelBlock;

    MPMediaPickerController *c = [[self alloc] initWithMediaTypes:mediaTypes];
    c.delegate = helper;
    
    static char associationKey;
    objc_setAssociatedObject(c, &associationKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return c;
}
@end

@implementation __MPMediaPickerController_MFBlockize_Helper
@synthesize didPickBlock, cancelBlock;

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    if (self.didPickBlock) {
        self.didPickBlock(mediaItemCollection);
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

@end