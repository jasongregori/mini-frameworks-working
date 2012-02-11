//
//  NSArray+MFSentence.m
//  zabbi
//
//  Created by Jason Gregori on 2/10/12.
//  Copyright 2010 Jason Gregori. All rights reserved.
//

#import "NSArray+MFSentence.h"


@implementation NSArray (MFSentence)

- (NSString *)mfSentence {
    return [self mfSentenceWithWordsConnector:NSLocalizedStringFromTable(@", ", @"NSArray+MFSentence", @"Sentence Words Connector")
                            twoWordsConnector:NSLocalizedStringFromTable(@" and ", @"NSArray+MFSentence", @"Sentence Two Words Connector")
                            lastWordConnector:NSLocalizedStringFromTable(@", and ", @"NSArray+MFSentence", @"Sentence Last Word Connector")];
}

- (NSString *)mfSentenceWithWordsConnector:(NSString *)wordsConnector
                         twoWordsConnector:(NSString *)twoWordsConnector
                         lastWordConnector:(NSString *)lastWordConnector {
    switch ([self count]) {
        case 0:
            return @"";
        case 1:
            return [[self objectAtIndex:0] description];
        case 2:
            return [self componentsJoinedByString:twoWordsConnector];
        default:
            return [NSString stringWithFormat:@"%@%@%@",
                    [[self subarrayWithRange:NSMakeRange(0, [self count] - 1)] componentsJoinedByString:wordsConnector],
                    lastWordConnector,
                    [self lastObject]];
    }
}

@end
