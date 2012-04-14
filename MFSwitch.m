//
//  MFSwitch.m
//  zabbi
//
//  Created by Jason Gregori on 4/12/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFSwitch.h"

@implementation MFSwitch

+ (id)objectSwitch:(id)object firstItemInList:(id)firstObject restOfList:(va_list)vl {
    // at first we passed an array instead of a va_list
    // this resulted in crashes because the array was retained and autoreleased after this scope and stack blocks were retained out of this scope
    id caseObj = firstObject;
    while (caseObj) {
        id retObj = va_arg(vl, id);
        
        if (caseObj && retObj) {
            // check for collections
            if ([caseObj isKindOfClass:[NSArray class]]
                || [caseObj isKindOfClass:[NSSet class]]) {
                if (object && [(NSArray *)caseObj containsObject:object]) {
                    return retObj;
                }
            }
            // otherwise check if equal
            if ([object isEqual:caseObj]) {
                return retObj;
            }
        }
        else {
            // if there is a caseObj but no retObj, caseObj must be the default object
            return caseObj;
        }
        
        caseObj = va_arg(vl, id);
    }
    
    return nil;
}

+ (id)objectSwitch:(id)object cases:(id)firstObject, ... {
    va_list vl; va_start(vl, firstObject);
    id ret = [self objectSwitch:object firstItemInList:firstObject restOfList:vl];
    va_end(vl);
    return ret;
}

+ (void)blockSwitch:(id)object cases:(id)firstObject, ... {
    va_list vl; va_start(vl, firstObject);
    void (^block)() = [self objectSwitch:object firstItemInList:firstObject restOfList:vl];
    va_end(vl);
    if (block) {
        block();
    }
}

+ (id)blockReturnSwitch:(id)object cases:(id)firstObject, ... {
    va_list vl; va_start(vl, firstObject);
    id (^block)() = [self objectSwitch:object firstItemInList:firstObject restOfList:vl];
    va_end(vl);
    if (block) {
        return block();
    }
    return nil;
}

@end
