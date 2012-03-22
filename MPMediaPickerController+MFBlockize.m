//
//  MPMediaPickerController+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 10/14/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "MPMediaPickerController+MFBlockize.h"

#import <objc/runtime.h>

typedef void (^__MPMediaPickerController_MFBlockize_DidPickBlock)(MPMediaPickerController *controller, MPMediaItemCollection *collection);
typedef void (^__MPMediaPickerController_MFBlockize_CancelBlock)(MPMediaPickerController *controller);

@interface __MPMediaPickerController_MFBlockize_Helper : NSObject <MPMediaPickerControllerDelegate>
@property (nonatomic, copy) __MPMediaPickerController_MFBlockize_DidPickBlock didPickBlock;
@property (nonatomic, copy) __MPMediaPickerController_MFBlockize_CancelBlock cancelBlock;
@end

@implementation MPMediaPickerController (MFBlockize)
+ (id)mfAnotherWithDidPickBlock:(__MPMediaPickerController_MFBlockize_DidPickBlock)didPickBlock
                    cancelBlock:(__MPMediaPickerController_MFBlockize_CancelBlock)cancelBlock {
    return [self mfAnotherWithMediaTypes:MPMediaTypeAny
                            didPickBlock:didPickBlock
                             cancelBlock:cancelBlock];
}
+ (id)mfAnotherWithMediaTypes:(MPMediaType)mediaTypes
                 didPickBlock:(__MPMediaPickerController_MFBlockize_DidPickBlock)didPickBlock
                  cancelBlock:(__MPMediaPickerController_MFBlockize_CancelBlock)cancelBlock {
    MPMediaPickerController *c = [[self alloc] initWithMediaTypes:mediaTypes];
    [c mfSetDidPickBlock:didPickBlock andCancelBlock:cancelBlock];
    return c;
}
- (void)mfSetDidPickBlock:(__MPMediaPickerController_MFBlockize_DidPickBlock)didPickBlock
           andCancelBlock:(__MPMediaPickerController_MFBlockize_CancelBlock)cancelBlock {
    __MPMediaPickerController_MFBlockize_Helper *helper = [__MPMediaPickerController_MFBlockize_Helper new];
    helper.didPickBlock = didPickBlock;
    helper.cancelBlock = cancelBlock;
    
    self.delegate = helper;
    
    static char associationKey;
    objc_setAssociatedObject(self, &associationKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation __MPMediaPickerController_MFBlockize_Helper
@synthesize didPickBlock, cancelBlock;

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    if (self.didPickBlock) {
        self.didPickBlock(mediaPicker, mediaItemCollection);
    }
    self.didPickBlock = nil;
    self.cancelBlock = nil;
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    if (self.cancelBlock) {
        self.cancelBlock(mediaPicker);
    }
    self.didPickBlock = nil;
    self.cancelBlock = nil;
}

@end