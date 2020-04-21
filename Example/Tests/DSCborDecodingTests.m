//
//  DSCborDecodingTests.m
//  TinyCborObjc_Tests
//
//  Created by Andrew Podkovyrin on 01/04/2019.
//  Copyright © 2019 Andrew Podkovyrin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <TinyCborObjc/NSData+DSCborDecoding.h>
#import <TinyCborObjc/NSObject+DSCborEncoding.h>

#import "TestsHelpers.h"

@interface DSCborDecodingTests : XCTestCase

@end

@implementation DSCborDecodingTests

- (void)testArrayDecoding {
    NSData *data = DATABYTES(0x82, 0x01, 0x02);
    NSError *error = nil;
    id decoded = [data ds_decodeCborError:&error];
    id result = @[ @1, @2 ];
    XCTAssertEqualObjects(decoded, result);
    XCTAssertNil(error);
}

- (void)testDictionaryDecoding {
    NSData *data = DATABYTES(0xA1, 0x63, 0x61, 0x62, 0x63, 0x18, 0x2A);
    NSError *error = nil;
    id decoded = [data ds_decodeCborError:&error];
    id result = @{ @"abc" : @42 };
    XCTAssertEqualObjects(decoded, result);
    XCTAssertNil(error);
}

- (void)testEmptyDataDecoding {
    NSData *data = DATABYTES();
    NSError *error = nil;
    id decoded = [data ds_decodeCborError:&error];
    XCTAssertNil(decoded);
    XCTAssertNotNil(error);
}

- (void)testEncodingAndDecoding {
    NSDictionary *json = @{
        @"key" : @"value",
        @"another key" : @"another value",
        @"other type key" : @[ @1, @2 ],
    };
    NSData *encoded = [json ds_cborEncodedObject];
    XCTAssertNotNil(encoded);

    NSError *error = nil;
    id decoded = [encoded ds_decodeCborError:&error];
    XCTAssertEqualObjects(decoded, json);
    XCTAssertNil(error);
}

- (void)testEncodingAndDecodingLargeString {
    NSString *str = [@"" stringByPaddingToLength:50000 withString: @"a" startingAtIndex:0];
    NSData *encoded = [str ds_cborEncodedObject];
    XCTAssertNotNil(encoded);
    
    NSError *error = nil;
    id decoded = [encoded ds_decodeCborError:&error];
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

    NSData *encoded = [dict ds_cborEncodedObject];
    XCTAssertNotNil(encoded);

    NSError *error = nil;
    NSDictionary *decoded = (NSDictionary *)[encoded ds_decodeCborError:&error];
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
    id decoded = [encoded ds_decodeCborError:&error];
    XCTAssertEqualObjects(decoded, d);
    XCTAssertNil(error);
}

- (void)testEncodingAndDecodingData {
    NSString *dataString = @"abc";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *d = @{ @"d" :
                             @[
                                @"str",
                                @42,
                                @{
                                   @"data" : data,
                                },
                             ],
    };

    NSData *encoded = [d ds_cborEncodedObject];
    XCTAssertNotNil(encoded);

    NSError *error = nil;
    id decoded = [encoded ds_decodeCborError:&error];
    XCTAssertEqualObjects(decoded, d);
    XCTAssertNil(error);
}

@end
