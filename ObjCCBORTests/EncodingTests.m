//
//  Created by Andrew Podkovyrin
//  Copyright © 2018 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <XCTest/XCTest.h>

#import <limits.h>

#import <ObjCCBOR/CBORRepresentable.h>
#import <ObjCCBOR/ObjCCBOR.h>

#import "TestsHelpers.h"

@interface DSCborEncodingTests : XCTestCase

@end

@implementation DSCborEncodingTests

- (void)testEncodeInts {
    for (uint8_t i = 0; i < 24; i++) {
        XCTAssertEqualObjects([CBOR encodeObject:@(i) error:nil],
                              DATABYTES(i));
    }

    XCTAssertEqualObjects([CBOR encodeObject:@(-1) error:nil],
                          DATABYTES(0x20));
    XCTAssertEqualObjects([CBOR encodeObject:@(-10) error:nil],
                          DATABYTES(0x29));
    XCTAssertEqualObjects([CBOR encodeObject:@(-24) error:nil],
                          DATABYTES(0x37));
    XCTAssertEqualObjects([CBOR encodeObject:@(-25) error:nil],
                          DATABYTES(0x38, 24));
    XCTAssertEqualObjects([CBOR encodeObject:@1000000 error:nil],
                          DATABYTES(0x1a, 0x00, 0x0f, 0x42, 0x40));
    XCTAssertEqualObjects([CBOR encodeObject:@4294967295 error:nil],
                          DATABYTES(0x1a, 0xff, 0xff, 0xff, 0xff));
    XCTAssertEqualObjects([CBOR encodeObject:@1000000000000 error:nil],
                          DATABYTES(0x1b, 0x00, 0x00, 0x00, 0xe8, 0xd4, 0xa5, 0x10, 0x00));
    XCTAssertEqualObjects([CBOR encodeObject:[NSNumber numberWithUnsignedLong:4294967295] error:nil],
                          DATABYTES(0x1a, 0xff, 0xff, 0xff, 0xff));
    XCTAssertEqualObjects([CBOR encodeObject:[NSNumber numberWithLong:-2147483648] error:nil],
                          DATABYTES(0x3b, 0xff, 0xff, 0xff, 0xff, 0x7f, 0xff, 0xff, 0xff));
    XCTAssertEqualObjects([CBOR encodeObject:[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] error:nil],
                          DATABYTES(0x1b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff));
    XCTAssertEqualObjects([CBOR encodeObject:[NSNumber numberWithLongLong:LLONG_MIN] error:nil],
                          DATABYTES(0x3b, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff));
}

- (void)testEncodeStrings {
    XCTAssertEqualObjects([CBOR encodeObject:@"" error:nil],
                          DATABYTES(0x60));
    XCTAssertEqualObjects([CBOR encodeObject:@"a" error:nil],
                          DATABYTES(0x61, 0x61));
    XCTAssertEqualObjects([CBOR encodeObject:@"B" error:nil],
                          DATABYTES(0x61, 0x42));
    XCTAssertEqualObjects([CBOR encodeObject:@"ABC" error:nil],
                          DATABYTES(0x63, 0x41, 0x42, 0x43));
    XCTAssertEqualObjects([CBOR encodeObject:@"IETF" error:nil],
                          DATABYTES(0x64, 0x49, 0x45, 0x54, 0x46));
    XCTAssertEqualObjects([CBOR encodeObject:@"今日は" error:nil],
                          DATABYTES(0x69, 0xE4, 0xBB, 0x8A, 0xE6, 0x97, 0xA5, 0xE3, 0x81, 0xAF));
    XCTAssertEqualObjects([CBOR encodeObject:@"♨️français;日本語！Longer text\n with break?"
                                     error:nil],
                          DATABYTES(0x78, 0x34, 0xe2, 0x99, 0xa8, 0xef, 0xb8, 0x8f, 0x66, 0x72,
                                    0x61, 0x6e, 0xc3, 0xa7, 0x61, 0x69, 0x73, 0x3b, 0xe6, 0x97,
                                    0xa5, 0xe6, 0x9c, 0xac, 0xe8, 0xaa, 0x9e, 0xef, 0xbc, 0x81,
                                    0x4c, 0x6f, 0x6e, 0x67, 0x65, 0x72, 0x20, 0x74, 0x65, 0x78,
                                    0x74, 0x0a, 0x20, 0x77, 0x69, 0x74, 0x68, 0x20, 0x62, 0x72,
                                    0x65, 0x61, 0x6b, 0x3f));
    XCTAssertEqualObjects([CBOR encodeObject:@"\"\\" error:nil],
                          DATABYTES(0x62, 0x22, 0x5c));
    XCTAssertEqualObjects([CBOR encodeObject:@"\u6C34" error:nil],
                          DATABYTES(0x63, 0xe6, 0xb0, 0xb4));
    XCTAssertEqualObjects([CBOR encodeObject:@"水" error:nil],
                          DATABYTES(0x63, 0xe6, 0xb0, 0xb4));
    XCTAssertEqualObjects([CBOR encodeObject:@"\u00fc" error:nil],
                          DATABYTES(0x62, 0xc3, 0xbc));
    XCTAssertEqualObjects([CBOR encodeObject:@"abc\n123" error:nil],
                          DATABYTES(0x67, 0x61, 0x62, 0x63, 0x0a, 0x31, 0x32, 0x33));
}

- (void)testEncodeSimple {
    XCTAssertEqualObjects([CBOR encodeObject:@NO error:nil],
                          DATABYTES(0xf4));
    XCTAssertEqualObjects([CBOR encodeObject:@YES error:nil],
                          DATABYTES(0xf5));
    XCTAssertEqualObjects([CBOR encodeObject:[NSNull null] error:nil],
                          DATABYTES(0xf6));
}

- (void)testEncodeFloats {
    // The following tests are modifications of examples of Float16 in the RFC
    XCTAssertEqualObjects([CBOR encodeObject:DSFLOAT(0.0) error:nil],
                          DATABYTES(0xfa, 0x00, 0x00, 0x00, 0x00));
    XCTAssertEqualObjects([CBOR encodeObject:DSFLOAT(-0.0) error:nil],
                          DATABYTES(0xfa, 0x80, 0x00, 0x00, 0x00));
    XCTAssertEqualObjects([CBOR encodeObject:DSFLOAT(1.0) error:nil],
                          DATABYTES(0xfa, 0x3f, 0x80, 0x00, 0x00));
    XCTAssertEqualObjects([CBOR encodeObject:DSFLOAT(1.5) error:nil],
                          DATABYTES(0xfa, 0x3f, 0xc0, 0x00, 0x00));
    XCTAssertEqualObjects([CBOR encodeObject:DSFLOAT(65504.0) error:nil],
                          DATABYTES(0xfa, 0x47, 0x7f, 0xe0, 0x00));

    // The following are seen as Float32s in the RFC
    XCTAssertEqualObjects([CBOR encodeObject:DSFLOAT(100000.0) error:nil],
                          DATABYTES(0xfa, 0x47, 0xc3, 0x50, 0x00));
    XCTAssertEqualObjects([CBOR encodeObject:DSFLOAT(3.4028234663852886e+38) error:nil],
                          DATABYTES(0xfa, 0x7f, 0x7f, 0xff, 0xff));

    // The following are seen as Doubles in the RFC
    XCTAssertEqualObjects([CBOR encodeObject:DSDOUBLE(1.1) error:nil],
                          DATABYTES(0xfb, 0x3f, 0xf1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a));
    XCTAssertEqualObjects([CBOR encodeObject:DSDOUBLE(-4.1) error:nil],
                          DATABYTES(0xfb, 0xc0, 0x10, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66));
    XCTAssertEqualObjects([CBOR encodeObject:DSDOUBLE(1.0e+300) error:nil],
                          DATABYTES(0xfb, 0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c));
    XCTAssertEqualObjects([CBOR encodeObject:DSDOUBLE(5.960464477539063e-8) error:nil],
                          DATABYTES(0xfb, 0x3e, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00));

    // Special values
    XCTAssertEqualObjects([CBOR encodeObject:DSDOUBLE(INFINITY) error:nil],
                          DATABYTES(0xfb, 0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00));
    XCTAssertEqualObjects([CBOR encodeObject:DSDOUBLE(-INFINITY) error:nil],
                          DATABYTES(0xfb, 0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00));
    XCTAssertEqualObjects([CBOR encodeObject:DSDOUBLE(NAN) error:nil],
                          DATABYTES(0xfb, 0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00));

    // These tests are failed because NSNumber internally stores INFINITY
    // as a double despite of numberWithFloat:
    //    XCTAssertEqualObjects([CBOR encodeObject:DSFLOAT(INFINITY) error:nil],
    //                          DATABYTES(0xfa, 0x7f, 0x80, 0x00, 0x00));
    //    XCTAssertEqualObjects([CBOR encodeObject:DSFLOAT(-INFINITY) error:nil],
    //                          DATABYTES(0xfa, 0xff, 0x80, 0x00, 0x00));
    //    XCTAssertEqualObjects([CBOR encodeObject:DSFLOAT(NAN) error:nil],
    //                          DATABYTES(0xfa, 0x7f, 0xc0, 0x00, 0x00));

    XCTAssertEqualObjects([CBOR encodeObject:DSDOUBLE(INFINITY) error:nil],
                          [CBOR encodeObject:DSFLOAT(INFINITY) error:nil]);
    XCTAssertEqualObjects([CBOR encodeObject:DSDOUBLE(-INFINITY) error:nil],
                          [CBOR encodeObject:DSFLOAT(-INFINITY) error:nil]);
    XCTAssertEqualObjects([CBOR encodeObject:DSDOUBLE(NAN) error:nil],
                          [CBOR encodeObject:DSFLOAT(NAN) error:nil]);
}

- (void)testEncodeArrays {
    XCTAssertEqualObjects([CBOR encodeObject:@[] error:nil],
                          DATABYTES(0x80));

    XCTAssertEqualObjects([CBOR encodeObject:(@[@1, @2, @3]) error:nil],
                          DATABYTES(0x83, 0x01, 0x02, 0x03));

    XCTAssertEqualObjects([CBOR encodeObject:(@[ @[ @1 ], @[ @2, @3 ], @[ @4, @5 ] ]) error:nil],
                          DATABYTES(0x83, 0x81, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05));

    NSMutableArray *ma = [NSMutableArray array];
    for (NSInteger i = 1; i <= 25; i++) {
        [ma addObject:@(i)];
    }
    XCTAssertEqualObjects([CBOR encodeObject:ma error:nil],
                          DATABYTES(0x98, 0x19, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
                                    0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12,
                                    0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x18, 0x18, 0x19));
}

- (void)testEncodeDictionaries {
    XCTAssertEqualObjects([CBOR encodeObject:@{} error:nil],
                          DATABYTES(0xa0));

    XCTAssertEqualObjects([CBOR encodeObject:(@{ @"x": @2, @"y": @4 }) error:nil],
                          DATABYTES(0xa2, 0x61, 0x78, 0x02, 0x61, 0x79, 0x04));

    XCTAssertEqualObjects([CBOR encodeObject:(@{ @"a": @[ @1 ], @"b": @[ @2, @3 ] }) error:nil],
                          DATABYTES(0xa2, 0x61, 0x61, 0x81, 0x01, 0x61, 0x62, 0x82, 0x02, 0x03));
}

- (void)testEncodeDataPayload {
    NSString *dataString = @"abc";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects([CBOR encodeObject:(@{@"data": data}) error:nil],
                          DATABYTES(0xa1, 0x64, 0x64, 0x61, 0x74, 0x61, 0x43, 0x61, 0x62, 0x63));
}

- (void)testEncodeCBORRepresentable {
    NSString *name = @"Sarah";
    NSDictionary *straightDict = @{@"the_name": name};

    NSData *expectedCBORBytes = DATABYTES(0xa1, 0x68, 0x74, 0x68, 0x65, 0x5f, 0x6e, 0x61, 0x6d, 0x65, 0x65,
                                          0x53, 0x61, 0x72, 0x61, 0x68);

    NSData *encodedDict = [CBOR encodeObject:straightDict error:nil];
    XCTAssertEqualObjects(encodedDict, expectedCBORBytes);

    MyCBORCompatibleObject *protocolConformingObj = [[MyCBORCompatibleObject alloc] initWithName:name];

    NSData *encodedConformingObj = [CBOR encodeObject:protocolConformingObj error:nil];
    XCTAssertEqualObjects(encodedConformingObj, expectedCBORBytes);
    XCTAssertEqualObjects(encodedConformingObj, encodedDict);
}

- (void)testEncodeNestedCBORRepresentable {
    NSString *name = @"Sarah";
    NSDictionary *straightDict = @{@"outer": @{@"the_name": name}};

    NSData *expectedCBORBytes = DATABYTES(0xa1, 0x65, 0x6f, 0x75, 0x74, 0x65, 0x72, 0xa1, 0x68, 0x74, 0x68,
                                          0x65, 0x5f, 0x6e, 0x61, 0x6d, 0x65, 0x65, 0x53, 0x61, 0x72, 0x61,
                                          0x68);

    NSData *encodedDict = [CBOR encodeObject:straightDict error:nil];
    XCTAssertEqualObjects(encodedDict, expectedCBORBytes);

    MyCBORCompatibleObject *protocolConformingObj = [[MyCBORCompatibleObject alloc] initWithName:name];
    NSDictionary *nestedObj = @{@"outer": protocolConformingObj};

    NSData *encodedNestedObj = [CBOR encodeObject:nestedObj error:nil];
    XCTAssertEqualObjects(encodedNestedObj, expectedCBORBytes);
    XCTAssertEqualObjects(encodedNestedObj, encodedDict);
}

@end
