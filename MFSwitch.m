//
//  MFSwitch.m
//  zabbi
//
//  Created by Jason Gregori on 4/12/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFSwitch.h"

@implementation MFSwitch

+ (id)objectSwitch:(id)object casesArray:(NSArray *)cases {
    id ret = nil;
    
    NSEnumerator *enumerator = [cases objectEnumerator];
    
    id caseObj = [enumerator nextObject];
    while (caseObj) {
        id retObj = [enumerator nextObject];
        
        if (caseObj && retObj) {
            // check for collections
            if ([caseObj isKindOfClass:[NSArray class]]
                || [caseObj isKindOfClass:[NSSet class]]) {
                if ([(NSArray *)caseObj containsObject:object]) {
                    ret = retObj;
                    break;
                }
            }
            // otherwise check if equal
            if ([object isEqual:caseObj]) {
                ret = retObj;
                break;
            }
        }
        else {
            // if there is an obj but no block, obj must be the default object
            ret = caseObj;
            break;
        }
        
        caseObj = [enumerator nextObject];
    }
    
    return ret;
}

+ (id)objectSwitch:(id)object cases:(id)firstObject, ... {
    NSMutableArray *args = [NSMutableArray array]; va_list vl; va_start(vl, firstObject); id o = firstObject; while (o) { [args addObject:o]; o = va_arg(vl, id); } va_end(vl);
    return [self objectSwitch:object casesArray:args];
}

+ (void)blockSwitch:(id)object cases:(id)firstObject, ... {
    NSMutableArray *args = [NSMutableArray array]; va_list vl; va_start(vl, firstObject); id o = firstObject; while (o) { [args addObject:o]; o = va_arg(vl, id); } va_end(vl);
    void (^block)() = [self objectSwitch:object casesArray:args];
    if (block) {
        block();
    }
}

+ (id)blockReturnSwitch:(id)object cases:(id)firstObject, ... {
    NSMutableArray *args = [NSMutableArray array]; va_list vl; va_start(vl, firstObject); id o = firstObject; while (o) { [args addObject:o]; o = va_arg(vl, id); } va_end(vl);
    id (^block)() = [self objectSwitch:object casesArray:args];
    if (block) {
        return block();
    }
    return nil;
}

@end
