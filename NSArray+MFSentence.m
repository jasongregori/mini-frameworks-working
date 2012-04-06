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

- (NSAttributedString *)mfAttributedSentenceWithWordAttributes:(NSDictionary *)wordAttributes
                                           connectorAttributes:(NSDictionary *)connectorAttributes {
    return [self mfAttributedSentenceWithWordsConnector:NSLocalizedStringFromTable(@", ", @"NSArray+MFSentence", @"The string to use for connecting words in a list together in a sentence. When there more than 2 words, this connects all the words except the last two: \"John{, }Jason{, }Bob, and Carl\"")
                                      twoWordsConnector:NSLocalizedStringFromTable(@" & ", @"NSArray+MFSentence", @"The string to use for connecting two words in a list together in a sentence: \"John{ & }Jason\"")
                                      lastWordConnector:NSLocalizedStringFromTable(@", and ", @"NSArray+MFSentence", @"The string to use for connecting words in a list together in a sentence. When there more than 2 words, this connects the last two: \"John, Jason, Bob{, and }Carl\"")
                                         wordAttributes:wordAttributes
                                    connectorAttributes:connectorAttributes];
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

- (NSAttributedString *)mfAttributedSentenceWithWordsConnector:(NSString *)wordsConnector
                                             twoWordsConnector:(NSString *)twoWordsConnector
                                             lastWordConnector:(NSString *)lastWordConnector
                                                wordAttributes:(NSDictionary *)wordAttributes
                                           connectorAttributes:(NSDictionary *)connectorAttributes {
    NSMutableArray *attributedStrings = [NSMutableArray new];
    for (id obj in self) {
        if ([obj isKindOfClass:[NSAttributedString class]]) {
            [attributedStrings addObject:obj];
        }
        else {
            [attributedStrings addObject:
             [[NSAttributedString alloc] initWithString:[obj description]
                                             attributes:wordAttributes]];
        }
    }
    
    switch ([self count]) {
        case 0:
            return [NSAttributedString new];
        case 1:
            return [attributedStrings objectAtIndex:0];
        case 2: {
            NSMutableAttributedString *string = [NSMutableAttributedString new];
            // add first word
            [string appendAttributedString:[attributedStrings objectAtIndex:0]];
            // add two word connector
            [string appendAttributedString:
             [[NSAttributedString alloc] initWithString:twoWordsConnector
                                             attributes:connectorAttributes]];
            // add last word
            [string appendAttributedString:[attributedStrings objectAtIndex:1]];
            return string;
        }
        default: {
            NSMutableAttributedString *string = [NSMutableAttributedString new];
            BOOL firstWord = YES;
            for (NSAttributedString *word in [attributedStrings subarrayWithRange:NSMakeRange(0, [self count] - 1)]) {
                if (!firstWord) {
                    // add word connector
                    [string appendAttributedString:
                     [[NSAttributedString alloc] initWithString:wordsConnector
                                                     attributes:connectorAttributes]];
                }
                // add word
                [string appendAttributedString:word];
                firstWord = NO;
            }
            // add last word connector
            [string appendAttributedString:
             [[NSAttributedString alloc] initWithString:lastWordConnector
                                             attributes:connectorAttributes]];
            // add last word
            [string appendAttributedString:[attributedStrings lastObject]];
            
            return string;
        }
    }
}

@end
