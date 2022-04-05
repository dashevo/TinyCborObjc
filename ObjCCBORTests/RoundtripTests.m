//
//  RoundtripTests.m
//  ObjCCBORTests
//
//  Created by Ham Chapman on 04/04/2022.
//  Copyright © 2022 Dash. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <limits.h>

#import <ObjCCBOR/ObjCCBOR.h>

#import "TestsHelpers.h"

@interface DSRoundtripTests : XCTestCase

@end

@implementation DSRoundtripTests

- (void)testRoundtripSimpleString {
    NSString *str = @"a";
    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:str error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertEqualObjects(decoded, str);
    XCTAssertNil(error);
}

- (void)testRoundtripStringsWithEscapedCharactersInDictionary {
    NSDictionary *dict = @{
        @"escaped": @"\"quotes\"",
        @"more": @"qu\"otes",
        @"back": @"sla\\sh",
        @"new": @"li\nne"
    };

    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:dict error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertEqualObjects(decoded, dict);
    XCTAssertNil(error);
}

- (void)testRoundtripSimpleDictionary {
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

- (void)testRoundtripDictionaryWithNonAsciiKeys {
    NSDictionary<NSString *, NSString *> *dict = @{@"£test£": @"¡€#¢•©˙∆åßƒ∫~µç≈Ω"};
    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:dict error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertEqualObjects(decoded, dict);
    XCTAssertNil(error);
}

- (void)testRoundtripInts {
    NSArray<NSNumber *> *integers = @[
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:1],
        [NSNumber numberWithUnsignedInt:1],
        [NSNumber numberWithInt:-1],
        [NSNumber numberWithUnsignedInt:UINT_MAX],
        [NSNumber numberWithInt:INT_MAX],
        [NSNumber numberWithInt:INT_MIN],
        [NSNumber numberWithInt:INT_MIN + 1],
        [NSNumber numberWithLong:2147483647],
        [NSNumber numberWithLong:LONG_MIN],
        [NSNumber numberWithUnsignedLong:ULONG_MAX],
        [NSNumber numberWithLongLong:LLONG_MAX],
        [NSNumber numberWithLongLong:LLONG_MIN],
        [NSNumber numberWithUnsignedLongLong:ULLONG_MAX],
    ];

    [integers enumerateObjectsUsingBlock:^(NSNumber * _Nonnull integer, NSUInteger idx, BOOL * _Nonnull stop) {
        NSError *error = nil;
        NSData *encoded = [CBOR encodeObject:integer error:&error];
        XCTAssertNil(error);
        XCTAssertNotNil(encoded);

        id decoded = [CBOR decodeData:encoded error:&error];
        XCTAssertNil(error);
        XCTAssertEqualObjects(decoded, integer);
    }];
}

- (void)testRoundtripLargeString {
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

- (void)testRoundtripLargeObject {
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

- (void)testRoundtripData {
    NSString *dataString = @"abc";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *dict = @{
        @"d": @[
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

- (void)testRoundtripRandomData {
    int numBytes = 64;
    NSMutableData *data = [NSMutableData dataWithCapacity:numBytes];
    for(unsigned int i = 0; i < numBytes/4; i++) {
        uint32_t randomBits = arc4random();
        [data appendBytes:(void*)&randomBits length:4];
    }

    NSDictionary *dict = @{
        @"d": @[
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