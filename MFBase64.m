//
//  MFBase64.m
//  zabbi
//
//  Created by Jason Gregori on 3/23/12.
//  Copyright (c) 2012 Jason Gregori. All rights reserved.
//

#import "MFBase64.h"

#import "limits.h"

@interface MFBase64 ()
+ (NSString *)__encodeData:(NSData *)data withEncodingTable:(const char *)encodingTable;
@end

@implementation MFBase64

+ (NSString *)encodeString:(NSString *)string {
    return [self encodeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)encodeData:(NSData *)data {
    static const char encodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    return [self __encodeData:data withEncodingTable:encodingTable];
}

+ (NSString *)encodeDataURLSafe:(NSData *)data {
    static const char encodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    return [self __encodeData:data withEncodingTable:encodingTable];
}

+ (NSString *)__encodeData:(NSData *)data withEncodingTable:(const char *)encodingTable {
    const char *bytes = [data bytes];
    NSUInteger length = [data length];
    
    int bytesize = CHAR_BIT;
    int indexsize = 6; // this is the size of the indexes that go into the encoding table
    NSAssert(bytesize >= indexsize, @"MFBase64: We assume bytesize >= indexsize and apparently thats not the case here. You're on your own!");

    int totalBits = length * bytesize;
    // total bits must be divisible by 24 (we add padding if we have less than that)
    int strlen = ceil((double)totalBits/24.0)*24/6;
    char *str = (char *)malloc(strlen * sizeof(char));

    int tindex = 0; // table index
    int sindex = 0; // str index
    int tbitsCaptured = 0; // t index bits captured
    // we are trying to fill indexsize bits into tindex and then capture the corresponding char
    for (int i = 0; i < length; i++) {
        char byte = bytes[i];

        int bBitsCaptured = 0; // the number of bits we've captured from byte
        int headBitsToCapture, tailBitsToCapture;
        do {
            headBitsToCapture = indexsize - tbitsCaptured;
            tailBitsToCapture = bytesize - bBitsCaptured - headBitsToCapture;
            // this is the number of bits to take from this byte and combine with the last captured bits
            // combine these bits with the last captured bits
            tindex = (tindex << headBitsToCapture) | ((byte << bBitsCaptured) >> (bytesize - headBitsToCapture));
            // we must have a full index here because indexsize < bytesize
            str[sindex++] = encodingTable[tindex & 63];
            tbitsCaptured = 0;
            bBitsCaptured += headBitsToCapture;
        } while (tailBitsToCapture >= indexsize);

        // capture the remaining bits
        if (tailBitsToCapture > 0) {
            tindex = byte;
            tbitsCaptured = tailBitsToCapture;
        }
    }
    // there could be a partial letter here
    if (tbitsCaptured > 0) {
        tindex = tindex << (indexsize - tbitsCaptured);
        str[sindex++] = encodingTable[tindex & 63];
    }
    // padding
    while (sindex < strlen) {
        str[sindex++] = '=';
    }
    
	return [[NSString alloc] initWithBytesNoCopy:str length:strlen encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

@end
