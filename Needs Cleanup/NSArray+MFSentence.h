//
//  NSArray+MFSentence.h
//  zabbi
//
//  Created by Jason Gregori on 2/10/12.
//  Copyright 2010 Jason Gregori. All rights reserved.
//

// @mf: Converts an array of objects to a sentence in the form of {object}, {object}, and {object}

#import <Foundation/Foundation.h>

@interface NSArray (MFSentence)

- (NSString *)mfSentence;
// ranges returns the range of every object in the sentence, it will have the same count as self
- (NSString *)mfSentenceWithWordRangeValues:(NSArray **)ranges;
// If a string is an attributed string, word attributes is not used. Otherwise word attributes is added to the string.
- (NSAttributedString *)mfAttributedSentenceWithWordAttributes:(NSDictionary *)wordAttributes
                                           connectorAttributes:(NSDictionary *)connectorAttributes;

/*
 wordsConnector - The string used to join the elements in a array with three or more elements.
 twoWordsConnector - The string used to join the elements in arrays with two elements.
 lastWordConnector - The string used to join the last element in arrays with three or more elements.
 */
- (NSString *)mfSentenceWithWordsConnector:(NSString *)wordsConnector
                         twoWordsConnector:(NSString *)twoWordsConnector
                         lastWordConnector:(NSString *)lastWordConnector;
- (NSAttributedString *)mfAttributedSentenceWithWordsConnector:(NSString *)wordsConnector
                                             twoWordsConnector:(NSString *)twoWordsConnector
                                             lastWordConnector:(NSString *)lastWordConnector
                                                wordAttributes:(NSDictionary *)wordAttributes
                                           connectorAttributes:(NSDictionary *)connectorAttributes;

@end
