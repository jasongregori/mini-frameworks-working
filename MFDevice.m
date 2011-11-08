//
//  MFDevice.m
//  zabbi
//
//  Created by Jason Gregori on 10/03/11.
//  Copyright 2011 Jason Gregori. All rights reserved.
//

#import "MFDevice.h"

#import <UIKit/UIKit.h>

BOOL mfOSIsAtLeast(NSString * version) {
    static NSString *currentVersion = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentVersion = [[UIDevice currentDevice] systemVersion];
    });
    return ([currentVersion compare:version options:NSNumericSearch] != NSOrderedAscending);
}

BOOL mfOnIPad() {
    static BOOL onIPad;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        onIPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    });
    return onIPad;
}