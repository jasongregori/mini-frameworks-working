//
//  MFIBTableViewCell.m
//  zabbi
//
//  Created by Jason Gregori on 7/14/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFIBTableViewCell.h"

#import <objc/runtime.h>

@implementation MFIBTableViewCell

// TODO: replace initWithFrame: so it throws an error

+ (id)cell {
    static char nibKey;
    UINib *nib = objc_getAssociatedObject(self, &nibKey);
    if (!nib) {
        nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:[NSBundle mainBundle]];
        objc_setAssociatedObject(self, &nibKey, nib, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    NSAssert([objects count], @"%@: +cell: We weren't able to load anything from the nib!", NSStringFromClass(self));
    id cell = [objects objectAtIndex:0];
    NSAssert([cell isKindOfClass:[self class]], @"%@: +cell: We didn't get an actual cell!", NSStringFromClass(self));
    return cell;
}

+ (NSString *)reuseIdentifier {
    static char riKey;
    NSString *ri = objc_getAssociatedObject(self, &riKey);
    if (!ri) {
        ri = [[self cell] reuseIdentifier];
        objc_setAssociatedObject(self, &riKey, ri, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ri;
}

+ (CGFloat)rowHeight {
    static char hKey;
    NSNumber *height = objc_getAssociatedObject(self, &hKey);
    if (!height) {
        height = [NSNumber numberWithFloat:[[self cell] bounds].size.height];
        objc_setAssociatedObject(self, &hKey, height, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [height floatValue];
}

@end
