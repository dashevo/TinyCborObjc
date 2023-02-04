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

- (void)testRoundtripDataAtRoot {
    NSString *dataString = @"abc";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:data error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertEqualObjects(decoded, data);
    XCTAssertNil(error);
}

- (void)testLargeNestedDictionaries {
    NSInteger numberOfEntries = 100;
    NSMutableDictionary *level1 = [[NSMutableDictionary alloc] initWithCapacity:numberOfEntries];

    for (int i = 0; i < numberOfEntries; i++) {
        NSMutableDictionary *level2 = [[NSMutableDictionary alloc] initWithCapacity:numberOfEntries];

        for (int j = 0; j < numberOfEntries; j += 1) {
            NSMutableDictionary *level3 = [[NSMutableDictionary alloc] initWithCapacity:numberOfEntries];

            for (int k = 0; k < numberOfEntries; k += 1) {
                NSString *key = [NSString stringWithFormat:@"key-k%@", @(k)];
                NSString *value = [NSString stringWithFormat:@"value-k%@", @(k)];
                level3[key] = value;
            }

            NSString *key = [NSString stringWithFormat:@"key-j%@", @(j)];
            NSString *value = [level3 copy];
            level2[key] = value;
        }

        NSString *key = [NSString stringWithFormat:@"key-i%@", @(i)];
        NSString *value = [level2 copy];
        level1[key] = value;
    }

    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:level1 error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertNotNil(decoded);
    XCTAssertTrue([decoded isKindOfClass:NSDictionary.class]);
    XCTAssertNil(error);

    NSDictionary *decodedLevel1 = decoded;
    XCTAssertEqual(decodedLevel1.count, numberOfEntries);

    for (int i = 0; i < decodedLevel1.count; i++) {
        NSString *key = [NSString stringWithFormat:@"key-i%@", @(i)];
        NSDictionary *decodedLevel2 = level1[key];
        XCTAssertEqual(decodedLevel2.count, numberOfEntries);

        for (int j = 0; j < decodedLevel2.count; j++) {
            NSString *key = [NSString stringWithFormat:@"key-j%@", @(j)];
            NSDictionary *decodedLevel3 = decodedLevel2[key];
            XCTAssertEqual(decodedLevel3.count, numberOfEntries);

            for (int k = 0; k < decodedLevel3.count; k++) {
                NSString *key = [NSString stringWithFormat:@"key-k%@", @(k)];
                NSString *value = decodedLevel3[key];
                NSString *expectedValue = [NSString stringWithFormat:@"value-k%@", @(k)];
                XCTAssertEqualObjects(value, expectedValue);
            }
        }
    }
}

- (void)testLargeNestedArrays {
    NSInteger numberOfEntries = 100;
    NSMutableArray *level1 = [[NSMutableArray alloc] initWithCapacity:numberOfEntries];

    for (int i = 0; i < numberOfEntries; i++) {
        NSMutableArray *level2 = [[NSMutableArray alloc] initWithCapacity:numberOfEntries];

        for (int j = 0; j < numberOfEntries; j += 1) {
            NSMutableArray *level3 = [[NSMutableArray alloc] initWithCapacity:numberOfEntries];

            for (int k = 0; k < numberOfEntries; k += 1) {
                NSString *entry = [NSString stringWithFormat:@"entry-%@", @(k)];
                [level3 addObject:entry];
            }

            NSArray *entry = [level3 copy];
            [level2 addObject:entry];
        }

        NSArray *entry = [level2 copy];
        [level1 addObject:entry];
    }

    NSError *error = nil;
    NSData *encoded = [CBOR encodeObject:level1 error:&error];
    XCTAssertNotNil(encoded);
    XCTAssertNil(error);

    id decoded = [CBOR decodeData:encoded error:&error];
    XCTAssertNotNil(decoded);
    XCTAssertTrue([decoded isKindOfClass:NSArray.class]);
    XCTAssertNil(error);

    NSArray *decodedLevel1 = decoded;
    XCTAssertEqual(decodedLevel1.count, numberOfEntries);

    for (int i = 0; i < decodedLevel1.count; i++) {
        NSArray *decodedLevel2 = level1[i];
        XCTAssertEqual(decodedLevel2.count, numberOfEntries);

        for (int j = 0; j < decodedLevel2.count; j++) {
            NSArray *decodedLevel3 = decodedLevel2[j];
            XCTAssertEqual(decodedLevel3.count, numberOfEntries);

            for (int k = 0; k < decodedLevel3.count; k++) {
                NSString *entry = decodedLevel3[k];
                NSString *expectedEntry = [NSString stringWithFormat:@"entry-%@", @(k)];
                XCTAssertEqualObjects(entry, expectedEntry);
            }
        }
    }
}

@end
