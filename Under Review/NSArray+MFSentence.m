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
                            lastWordConnector:NSLocalizedStringFromTable(@", and ", @"NSArray+MFSentence", @"The string to use for connecting words in a list together in a sentence. When there more than 2 words, this connects the last two: \"John, Jason, Bob{, and }Carl\"")
                          withWordRangeValues:NULL];
}

- (NSString *)mfSentenceWithWordRangeValues:(NSArray **)ranges {
    return [self mfSentenceWithWordsConnector:NSLocalizedStringFromTable(@", ", @"NSArray+MFSentence", @"The string to use for connecting words in a list together in a sentence. When there more than 2 words, this connects all the words except the last two: \"John{, }Jason{, }Bob, and Carl\"")
                            twoWordsConnector:NSLocalizedStringFromTable(@" & ", @"NSArray+MFSentence", @"The string to use for connecting two words in a list together in a sentence: \"John{ & }Jason\"")
                            lastWordConnector:NSLocalizedStringFromTable(@", and ", @"NSArray+MFSentence", @"The string to use for connecting words in a list together in a sentence. When there more than 2 words, this connects the last two: \"John, Jason, Bob{, and }Carl\"")
                          withWordRangeValues:ranges];
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
    return [self mfSentenceWithWordsConnector:wordsConnector
                            twoWordsConnector:twoWordsConnector
                            lastWordConnector:lastWordConnector
                          withWordRangeValues:NULL];
}

- (NSString *)mfSentenceWithWordsConnector:(NSString *)wordsConnector
                         twoWordsConnector:(NSString *)twoWordsConnector
                         lastWordConnector:(NSString *)lastWordConnector
                       withWordRangeValues:(NSArray **)rangesPointer {
    NSString *ret;
    NSMutableArray *ranges = (rangesPointer == NULL ? nil : [NSMutableArray new]);
    switch ([self count]) {
        case 0:
            return @"";
        case 1: {
            ret = [[self objectAtIndex:0] description];
            if (ranges) {
                [ranges addObject:[NSValue valueWithRange:NSMakeRange(0, ret.length)]];
            }
            break;
        }
        case 2: {
            NSString *first = [[self objectAtIndex:0] description];
            NSString *last = [[self objectAtIndex:1] description];
            ret = [NSString stringWithFormat:@"%@%@%@", first, twoWordsConnector, last];
            if (ranges) {
                [ranges addObject:[NSValue valueWithRange:NSMakeRange(0, first.length)]];
                [ranges addObject:[NSValue valueWithRange:NSMakeRange(ret.length-last.length, last.length)]];
            }
            break;
        }
        default: {
            NSMutableString *string = [NSMutableString new];
            NSUInteger i, count = [self count];
            for (i = 0; i < count; i++) {
                NSString *s = [[self objectAtIndex:i] description];

                if (i+2 >= count) {
                    // this is the second to last item
                    NSString *last = [[self objectAtIndex:i+1] description];
                    if (ranges) {
                        [ranges addObject:[NSValue valueWithRange:NSMakeRange(string.length, s.length)]];
                        [ranges addObject:[NSValue valueWithRange:NSMakeRange(string.length+s.length+lastWordConnector.length, last.length)]];
                    }
                    [string appendString:s];
                    [string appendString:lastWordConnector];
                    [string appendString:last];
                    break;
                }
                // this is an earlier item
                if (ranges) {
                    [ranges addObject:[NSValue valueWithRange:NSMakeRange(string.length, s.length)]];
                }
                [string appendString:s];
                [string appendString:wordsConnector];
            }
            ret = string;
            break;
        }
    }
    
    if (ranges) {
        *rangesPointer = ranges;
    }
    return ret;
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
