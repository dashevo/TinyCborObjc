//
//  DecodingTests.m
//  ObjCCBOR_Tests
//
//  Created by Andrew Podkovyrin on 01/04/2019.
//  Copyright © 2019 Andrew Podkovyrin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <ObjCCBOR/ObjCCBOR.h>

#import "TestsHelpers.h"

@interface DSCborDecodingTests : XCTestCase

@end

@implementation DSCborDecodingTests

- (void)testArrayDecoding {
    NSData *data = DATABYTES(0x82, 0x01, 0x02);
    NSError *error = nil;
    id decoded = [CBOR decodeData:data error:&error];
    id result = @[ @1, @2 ];
    XCTAssertEqualObjects(decoded, result);
    XCTAssertNil(error);
}

- (void)testEncodingAndDecodingADictionaryWithNonAsciiKeys {
    NSDictionary<NSString *, NSString *> *dict = @{
                                                   @"£test£": @"¡€#¢•©˙∆åßƒ∫~µç≈Ω"
                                                   };
    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:dict error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertEqualObjects(decoded, dict);
    XCTAssertNil(error);
}

- (void)testDictionaryDecoding {
    NSData *data = DATABYTES(0xA1, 0x63, 0x61, 0x62, 0x63, 0x18, 0x2A);
    NSError *error = nil;
    id decoded = [CBOR decodeData:data error:&error];
    id result = @{ @"abc" : @42 };
    XCTAssertEqualObjects(decoded, result);
    XCTAssertNil(error);
}

- (void)testEmptyDataDecoding {
    NSData *data = DATABYTES();
    NSError *error = nil;
    id decoded = [CBOR decodeData:data error:&error];
    XCTAssertNil(decoded);
    XCTAssertNotNil(error);
}

- (void)testEncodingAndDecoding {
    NSDictionary *json = @{
        @"key" : @"value",
        @"another key" : @"another value",
        @"other type key" : @[ @1, @2 ],
    };
    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:json error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertEqualObjects(decoded, json);
    XCTAssertNil(error);
}

- (void)testEncodingAndDecodingLargeString {
    NSString *str = [@"" stringByPaddingToLength:50000 withString: @"a" startingAtIndex:0];
    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:str error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertEqual(((NSString *)decoded).length, 50000);
    XCTAssertEqualObjects(decoded, str);
    XCTAssertNil(error);
}

- (void)testEncodingAndDecodingLargeObject {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity: 26];

    for (NSUInteger i = 0; i < 26; i++) {
        NSString *character = [[NSString alloc] initWithFormat:@"%c", (int)('a' + i)];
        NSString *str = [@"" stringByPaddingToLength:50000 withString: character startingAtIndex:0];
        dict[character] = str;
    }

    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:dict error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    NSDictionary *decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertNil(error);

    NSString *aString = (NSString *)decoded[@"a"];
    NSCharacterSet *notA = [[NSCharacterSet characterSetWithCharactersInString: @"a"] invertedSet];
    XCTAssertEqual([aString rangeOfCharacterFromSet:notA].location, NSNotFound);
    XCTAssertEqual(aString.length, 50000);

    NSString *zString = (NSString *)decoded[@"z"];
    NSCharacterSet *notZ = [[NSCharacterSet characterSetWithCharactersInString: @"z"] invertedSet];
    XCTAssertEqual([zString rangeOfCharacterFromSet:notZ].location, NSNotFound);
    XCTAssertEqual(zString.length, 50000);
}

- (void)testDecodingData {
    NSData *encoded = DATABYTES(0xa1, 0x64, 0x64, 0x61, 0x74, 0x61, 0x43, 0x61, 0x62, 0x63);
    NSString *dataString = @"abc";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *d = @{ @"data" : data };
    NSError *error = nil;
    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertEqualObjects(decoded, d);
    XCTAssertNil(error);
}

- (void)testEncodingAndDecodingData {
    NSString *dataString = @"abc";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *dict = @{
        @"d" :
            @[
                @"str",
                @42,
                @{
                    @"data" : data,
                }
            ]
    };

    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:dict error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertEqualObjects(decoded, dict);
    XCTAssertNil(error);
}

- (void)testEncodingAndDecodingASimpleString {
    NSString *str = @"a";
    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:str error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertEqualObjects(decoded, str);
    XCTAssertNil(error);
}

- (void)testEncodingAndDecodingRandomData {
    int numBytes = 64;
    NSMutableData *data = [NSMutableData dataWithCapacity:numBytes];
    for(unsigned int i = 0; i < numBytes/4; i++) {
        uint32_t randomBits = arc4random();
        [data appendBytes:(void*)&randomBits length:4];
    }

    NSDictionary *dict = @{
        @"d" :
            @[
                @"str",
                @42,
                @{
                    @"data" : data,
                }
            ]
    };

    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:dict error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertEqualObjects(decoded, dict);
    XCTAssertNil(error);
}

@end
