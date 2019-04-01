//
//  DSCborDecodingTests.m
//  TinyCborObjc_Tests
//
//  Created by Andrew Podkovyrin on 01/04/2019.
//  Copyright © 2019 Andrew Podkovyrin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <TinyCborObjc/NSData+DSCborDecoding.h>

#import "TestsHelpers.h"

@interface DSCborDecodingTests : XCTestCase

@end

@implementation DSCborDecodingTests

- (void)testArrayDecoding {
    NSData *data = DATABYTES(0x82, 0x01, 0x02);
    size_t outBufferSize = 1024; // 1 Kb
    NSError *error = nil;
    id decoded = [data ds_decodeCborWithOutBufferSize:outBufferSize
                                                error:&error];
    id result = @[ @1, @2 ];
    XCTAssertEqualObjects(decoded, result);
    XCTAssertNil(error);
}

- (void)testDictionaryDecoding {
    NSData *data = DATABYTES(0xA1, 0x63, 0x61, 0x62, 0x63, 0x18, 0x2A);
    size_t outBufferSize = 1024; // 1 Kb
    NSError *error = nil;
    id decoded = [data ds_decodeCborWithOutBufferSize:outBufferSize
                                                error:&error];
    id result = @{ @"abc" : @42 };
    XCTAssertEqualObjects(decoded, result);
    XCTAssertNil(error);
}

- (void)testNotEnoughtBufferDecoding {
    NSData *data = DATABYTES(0xA1, 0x63, 0x61, 0x62, 0x63, 0x18, 0x2A);
    size_t outBufferSize = 2; // 2 b
    NSError *error = nil;
    id decoded = [data ds_decodeCborWithOutBufferSize:outBufferSize
                                                error:&error];
    XCTAssertNil(decoded);
    XCTAssertNotNil(error);
}

- (void)testEmptyDataDecoding {
    NSData *data = DATABYTES();
    size_t outBufferSize = 1024; // 1 Kb
    NSError *error = nil;
    id decoded = [data ds_decodeCborWithOutBufferSize:outBufferSize
                                                error:&error];
    XCTAssertNil(decoded);
    XCTAssertNotNil(error);
}

@end
