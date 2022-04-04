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

@end
