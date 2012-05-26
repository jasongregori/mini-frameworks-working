//
//  MFButtonThatsVeryCustomizable.m
//  zabbi
//
//  Created by Jason Gregori on 10/10/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFButtonThatsVeryCustomizable.h"

@interface MFButtonThatsVeryCustomizable ()
@property (nonatomic, strong) NSMutableDictionary *__mfContentLookup;
@end

@implementation MFButtonThatsVeryCustomizable
@synthesize __mfContentLookup;

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.__mfContentLookup = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.__mfContentLookup = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)setCustomizationBlock:(void (^)(MFButtonThatsVeryCustomizable *button))block
                     forState:(UIControlState)state {
    [self.__mfContentLookup setObject:[block copy]
                               forKey:[NSNumber numberWithUnsignedInteger:state]];
    if (self.state == state) {
        [self mfLayoutCustomizations];
    }
}

- (void)mfLayoutCustomizations {
    void (^block)(MFButtonThatsVeryCustomizable *button) = 
    [self.__mfContentLookup objectForKey:[NSNumber numberWithUnsignedInteger:self.state]];
    if (!block) {
        block = [self.__mfContentLookup objectForKey:[NSNumber numberWithUnsignedInteger:UIControlStateNormal]];
    }
    if (block) {
        block(self);
    }
}

#pragma mark - UIButton

- (void)setSelected:(BOOL)newSelected {
    [super setSelected:newSelected];
    [self mfLayoutCustomizations];
}

- (void)setHighlighted:(BOOL)newHighlighted {
    [super setHighlighted:newHighlighted];
    [self mfLayoutCustomizations];
}

- (void)setEnabled:(BOOL)newEnabled {
    [super setEnabled:newEnabled];
    [self mfLayoutCustomizations];
}

@end
