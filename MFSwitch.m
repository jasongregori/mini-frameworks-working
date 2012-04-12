//
//  MFSwitch.m
//  zabbi
//
//  Created by Jason Gregori on 4/12/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFSwitch.h"

@implementation MFSwitch

+ (void)switch:(id)object cases:(id)firstObject, ... {
    va_list vl;
    va_start(vl, firstObject);
    id obj = firstObject;
    while (obj) {
        void (^block)() = va_arg(vl, void (^)());
        
        if (obj && block) {
            // check for collections
            if ([obj isKindOfClass:[NSArray class]]
                || [obj isKindOfClass:[NSSet class]]) {
                if ([(NSArray *)obj containsObject:object]) {
                    block();
                    break;
                }
            }
            // otherwise check if equal
            if ([object isEqual:obj]) {
                block();
                break;
            }
        }
        else {
            // if there is an obj but no block, obj must be the default block
            block = (void (^)())obj;
            block();
            break;
        }
        
        obj = va_arg(vl, id);
    }
    va_end(vl);
}

+ (id)returnSwitch:(id)object cases:(id)firstObject, ... {
    id ret = nil;
    va_list vl;
    va_start(vl, firstObject);
    id obj = firstObject;
    while (obj) {
        id (^block)() = va_arg(vl, id (^)());
        
        if (obj && block) {
            // check for collections
            if ([obj isKindOfClass:[NSArray class]]
                || [obj isKindOfClass:[NSSet class]]) {
                if ([(NSArray *)obj containsObject:object]) {
                    ret = block();
                    break;
                }
            }
            // otherwise check if equal
            if ([object isEqual:obj]) {
                ret = block();
                break;
            }
        }
        else {
            // if there is an obj but no block, obj must be the default block
            block = (id (^)())obj;
            ret = block();
            break;
        }
        
        obj = va_arg(vl, id);
    }
    va_end(vl);
    
    return ret;
}

@end
