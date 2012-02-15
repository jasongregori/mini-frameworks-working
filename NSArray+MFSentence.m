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
    return [self mfSentenceWithWordsConnector:NSLocalizedStringFromTable(@", ", @"NSArray+MFSentence", @"The string to use for connecting words in a list together in a sentence. When there more than 2 words, this connects all the words except the last two: \"John{, }Jason{, }Bob, and Carl\"")
                            twoWordsConnector:NSLocalizedStringFromTable(@" & ", @"NSArray+MFSentence", @"The string to use for connecting two words in a list together in a sentence: \"John{ & }Jason\"")
                            lastWordConnector:NSLocalizedStringFromTable(@", and ", @"NSArray+MFSentence", @"The string to use for connecting words in a list together in a sentence. When there more than 2 words, this connects the last two: \"John, Jason, Bob{, and }Carl\"")];
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
