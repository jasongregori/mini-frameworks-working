//
//  UIImagePickerController+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 10/21/11.
//  Copyright (c) 2011 Jason Gregori. All rights reserved.
//

#import "UIImagePickerController+MFBlockize.h"

#import <objc/runtime.h>

@interface __UIImagePickerController_MFBlockize_Helper : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, copy) void (^didPickBlock)(NSDictionary *mediaInfo);
@property (nonatomic, copy) void (^cancelBlock)();
@end

@implementation UIImagePickerController (MFBlockize)

+ (id)mfAnotherWithDidFinishPickingBlock:(void (^)(NSDictionary *mediaInfo))didPickBlock
                             cancelBlock:(void (^)())cancelBlock {
    UIImagePickerController *c = [self new];
    [c mfAddDidFinishPickingBlock:didPickBlock cancelBlock:cancelBlock];
    return c;
}

- (void)mfAddDidFinishPickingBlock:(void (^)(NSDictionary *mediaInfo))didPickBlock
                       cancelBlock:(void (^)())cancelBlock {
    __UIImagePickerController_MFBlockize_Helper *helper = [__UIImagePickerController_MFBlockize_Helper new];
    helper.didPickBlock = didPickBlock;
    helper.cancelBlock = cancelBlock;
    
    self.delegate = helper;
    
    static char associationKey;
    objc_setAssociatedObject(self, &associationKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation __UIImagePickerController_MFBlockize_Helper
@synthesize didPickBlock, cancelBlock;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (self.didPickBlock) {
        self.didPickBlock(info);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

@end