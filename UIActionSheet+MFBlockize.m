//
//  UIActionSheet+MFBlockize.m
//  zabbi
//
//  Created by Jason Gregori on 8/18/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "UIActionSheet+MFBlockize.h"

#import <objc/runtime.h>

@interface __UIActionSheet_MFBlockize_Helper : NSObject <UIActionSheetDelegate>
+ (__UIActionSheet_MFBlockize_Helper *)helperForActionSheet:(UIActionSheet *)sheet;
- (void)addBlock:(void (^)())block forButtonIndex:(NSUInteger)index;
@end

@implementation UIActionSheet (MFBlockize)

static UIActionSheet *__vmfAnotherWith(NSString *title, 
                                       NSString *cancelTitle, 
                                       void (^cancelBlock)(),
                                       NSString *destructiveTitle,
                                       void (^destructiveBlock)(),
                                       NSString *firstOtherButtonTitle,
                                       va_list otherButtonTitlesAndBlocks) {
    // you must set the destructive button here otherwise it doesn't always go the right place
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:destructiveTitle
                                               otherButtonTitles:nil];
    
    __UIActionSheet_MFBlockize_Helper *helper = [__UIActionSheet_MFBlockize_Helper helperForActionSheet:sheet];
    
    NSString *buttonTitle = firstOtherButtonTitle;
    while (buttonTitle) {
        void (^buttonBlock)() = va_arg(otherButtonTitlesAndBlocks, void (^)());
        [helper addBlock:buttonBlock forButtonIndex:[sheet addButtonWithTitle:buttonTitle]];
        
        buttonTitle = va_arg(otherButtonTitlesAndBlocks, NSString *);
    }
    
    // you must set the cancel button here to put it in the correct spot
    if (cancelTitle) {
        NSInteger index = [sheet addButtonWithTitle:cancelTitle];
        [helper addBlock:cancelBlock forButtonIndex:index];
        sheet.cancelButtonIndex = index;
    }
    if (destructiveTitle) {
        [helper addBlock:destructiveBlock forButtonIndex:sheet.destructiveButtonIndex];
    }
    
    return sheet;
}
                                       

+ (id)mfAnotherWithTitle:(NSString *)title
otherButtonTitlesAndBlocks:(NSString *)firstTitle, ... {
    
    va_list titlesAndBlocks;
    va_start(titlesAndBlocks, firstTitle);
    UIActionSheet *sheet = __vmfAnotherWith(title, 
                                            nil, 
                                            nil,
                                            nil,
                                            nil,
                                            firstTitle,
                                            titlesAndBlocks);
    va_end(titlesAndBlocks);
    
    return sheet;
}
+ (id)mfAnotherWithTitle:(NSString *)title
       cancelButtonTitle:(NSString *)cancelTitle
                   block:(void (^)())cancelBlock
otherButtonTitlesAndBlocks:(NSString *)firstTitle, ... {
    
    va_list titlesAndBlocks;
    va_start(titlesAndBlocks, firstTitle);
    UIActionSheet *sheet = __vmfAnotherWith(title, 
                                            cancelTitle, 
                                            cancelBlock,
                                            nil,
                                            nil,
                                            firstTitle,
                                            titlesAndBlocks);
    va_end(titlesAndBlocks);
    
    return sheet;
}
+ (id)mfAnotherWithTitle:(NSString *)title
       cancelButtonTitle:(NSString *)cancelTitle
                   block:(void (^)())cancelBlock
  destructiveButtonTitle:(NSString *)destructiveTitle
                   block:(void (^)())destructiveBlock
otherButtonTitlesAndBlocks:(NSString *)firstTitle, ... {

    va_list titlesAndBlocks;
    va_start(titlesAndBlocks, firstTitle);
    UIActionSheet *sheet = __vmfAnotherWith(title, 
                                            cancelTitle, 
                                            cancelBlock,
                                            destructiveTitle,
                                            destructiveBlock,
                                            firstTitle,
                                            titlesAndBlocks);
    va_end(titlesAndBlocks);
    
    return sheet;
}

- (NSUInteger)mfAddButtonWithTitle:(NSString *)title block:(void (^)())block {
    NSUInteger index = [self addButtonWithTitle:title];
    [[__UIActionSheet_MFBlockize_Helper helperForActionSheet:self] addBlock:block forButtonIndex:index];
    return index;
}

@end

@interface __UIActionSheet_MFBlockize_Helper ()
@property (nonatomic, strong) NSMutableDictionary *indexToBlock;
@end

@implementation __UIActionSheet_MFBlockize_Helper
@synthesize indexToBlock;

+ (__UIActionSheet_MFBlockize_Helper *)helperForActionSheet:(UIActionSheet *)sheet {
    static char associationKey;
    __UIActionSheet_MFBlockize_Helper *helper = objc_getAssociatedObject(sheet, &associationKey);
    if (!helper) {
        helper = [[__UIActionSheet_MFBlockize_Helper alloc] init];
        sheet.delegate = helper;
        objc_setAssociatedObject(sheet, &associationKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return helper;
}

- (id)init {
    self = [super init];
    if (self) {
        self.indexToBlock = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)addBlock:(void (^)())block forButtonIndex:(NSUInteger)index {
    if (block) {
        [self.indexToBlock setObject:[block copy]
                              forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^block)() = [self.indexToBlock objectForKey:[NSNumber numberWithUnsignedInteger:buttonIndex]];
    if (block) {
        block();
    }
}

@end