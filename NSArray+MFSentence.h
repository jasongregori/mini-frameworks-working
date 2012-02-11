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

/*
 wordsConnector - The string used to join the elements in a array with three or more elements.
 twoWordsConnector - The string used to join the elements in arrays with two elements.
 lastWordConnector - The string used to join the last element in arrays with three or more elements.
 */
- (NSString *)mfSentenceWithWordsConnector:(NSString *)wordsConnector
                         twoWordsConnector:(NSString *)twoWordsConnector
                         lastWordConnector:(NSString *)lastWordConnector;

@end
