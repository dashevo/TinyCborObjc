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

#import <TinyCborObjc/NSObject+DSCborEncoding.h>

#import "TestsHelpers.h"

@import XCTest;

@interface DSCborEncodingTests : XCTestCase

@end

@implementation DSCborEncodingTests

- (void)testEncodeInts {
    for (uint8_t i = 0; i < 24; i++) {
        XCTAssertEqualObjects([@(i) ds_cborEncodedObject], DATABYTES(i));
    }
    
    XCTAssertEqualObjects([@(-1) ds_cborEncodedObject], DATABYTES(0x20));
    XCTAssertEqualObjects([@(-10) ds_cborEncodedObject], DATABYTES(0x29));
    XCTAssertEqualObjects([@(-24) ds_cborEncodedObject], DATABYTES(0x37));
    XCTAssertEqualObjects([@(-25) ds_cborEncodedObject], DATABYTES(0x38, 24));
    XCTAssertEqualObjects([@1000000 ds_cborEncodedObject], DATABYTES(0x1a, 0x00, 0x0f, 0x42, 0x40));
    XCTAssertEqualObjects([@4294967295 ds_cborEncodedObject], DATABYTES(0x1a, 0xff, 0xff, 0xff, 0xff));
    XCTAssertEqualObjects([@1000000000000 ds_cborEncodedObject], DATABYTES(0x1b, 0x00, 0x00, 0x00, 0xe8, 0xd4, 0xa5, 0x10, 0x00));
}

- (void)testEncodeStrings {
    XCTAssertEqualObjects([@"" ds_cborEncodedObject], DATABYTES(0x60));
    XCTAssertEqualObjects([@"a" ds_cborEncodedObject], DATABYTES(0x61, 0x61));
    XCTAssertEqualObjects([@"B" ds_cborEncodedObject], DATABYTES(0x61, 0x42));
    XCTAssertEqualObjects([@"ABC" ds_cborEncodedObject], DATABYTES(0x63, 0x41, 0x42, 0x43));
    XCTAssertEqualObjects([@"IETF" ds_cborEncodedObject], DATABYTES(0x64, 0x49, 0x45, 0x54, 0x46));
    XCTAssertEqualObjects([@"今日は" ds_cborEncodedObject], DATABYTES(0x69, 0xE4, 0xBB, 0x8A, 0xE6, 0x97, 0xA5, 0xE3, 0x81, 0xAF));
    XCTAssertEqualObjects([@"♨️français;日本語！Longer text\n with break?" ds_cborEncodedObject], DATABYTES(0x78, 0x34, 0xe2, 0x99, 0xa8, 0xef, 0xb8, 0x8f, 0x66, 0x72, 0x61, 0x6e, 0xc3, 0xa7, 0x61, 0x69, 0x73, 0x3b, 0xe6, 0x97, 0xa5, 0xe6, 0x9c, 0xac, 0xe8, 0xaa, 0x9e, 0xef, 0xbc, 0x81, 0x4c, 0x6f, 0x6e, 0x67, 0x65, 0x72, 0x20, 0x74, 0x65, 0x78, 0x74, 0x0a, 0x20, 0x77, 0x69, 0x74, 0x68, 0x20, 0x62, 0x72, 0x65, 0x61, 0x6b, 0x3f));
    XCTAssertEqualObjects([@"\"\\" ds_cborEncodedObject], DATABYTES(0x62, 0x22, 0x5c));
    XCTAssertEqualObjects([@"\u6C34" ds_cborEncodedObject], DATABYTES(0x63, 0xe6, 0xb0, 0xb4));
    XCTAssertEqualObjects([@"水" ds_cborEncodedObject], DATABYTES(0x63, 0xe6, 0xb0, 0xb4));
    XCTAssertEqualObjects([@"\u00fc" ds_cborEncodedObject], DATABYTES(0x62, 0xc3, 0xbc));
    XCTAssertEqualObjects([@"abc\n123" ds_cborEncodedObject], DATABYTES(0x67, 0x61, 0x62, 0x63, 0x0a, 0x31, 0x32, 0x33));
}

- (void)testEncodeSimple {
    XCTAssertEqualObjects([@NO ds_cborEncodedObject], DATABYTES(0xf4));
    XCTAssertEqualObjects([@YES ds_cborEncodedObject], DATABYTES(0xf5));
    XCTAssertEqualObjects([[NSNull null] ds_cborEncodedObject], DATABYTES(0xf6));
}

- (void)testEncodeFloats {
    // The following tests are modifications of examples of Float16 in the RFC
    XCTAssertEqualObjects([DSFLOAT(0.0) ds_cborEncodedObject], DATABYTES(0xfa, 0x00, 0x00, 0x00, 0x00));
    XCTAssertEqualObjects([DSFLOAT(-0.0) ds_cborEncodedObject], DATABYTES(0xfa, 0x80, 0x00, 0x00, 0x00));
    XCTAssertEqualObjects([DSFLOAT(1.0) ds_cborEncodedObject], DATABYTES(0xfa, 0x3f, 0x80, 0x00, 0x00));
    XCTAssertEqualObjects([DSFLOAT(1.5) ds_cborEncodedObject], DATABYTES(0xfa,0x3f,0xc0, 0x00,0x00));
    XCTAssertEqualObjects([DSFLOAT(65504.0) ds_cborEncodedObject], DATABYTES(0xfa, 0x47, 0x7f, 0xe0, 0x00));
    
    // The following are seen as Float32s in the RFC
    XCTAssertEqualObjects([DSFLOAT(100000.0) ds_cborEncodedObject], DATABYTES(0xfa,0x47,0xc3,0x50,0x00));
    XCTAssertEqualObjects([DSFLOAT(3.4028234663852886e+38) ds_cborEncodedObject], DATABYTES(0xfa, 0x7f, 0x7f, 0xff, 0xff));
    
    // The following are seen as Doubles in the RFC
    XCTAssertEqualObjects([DSDOUBLE(1.1) ds_cborEncodedObject], DATABYTES(0xfb,0x3f,0xf1,0x99,0x99,0x99,0x99,0x99,0x9a));
    XCTAssertEqualObjects([DSDOUBLE(-4.1) ds_cborEncodedObject], DATABYTES(0xfb, 0xc0, 0x10, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66));
    XCTAssertEqualObjects([DSDOUBLE(1.0e+300) ds_cborEncodedObject], DATABYTES(0xfb, 0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c));
    XCTAssertEqualObjects([DSDOUBLE(5.960464477539063e-8) ds_cborEncodedObject], DATABYTES(0xfb, 0x3e, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00));
    
    // Special values
    XCTAssertEqualObjects([DSDOUBLE(INFINITY) ds_cborEncodedObject], DATABYTES(0xfb, 0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00));
    XCTAssertEqualObjects([DSDOUBLE(-INFINITY) ds_cborEncodedObject], DATABYTES(0xfb, 0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00));
    XCTAssertEqualObjects([DSDOUBLE(NAN) ds_cborEncodedObject], DATABYTES(0xfb, 0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00));
    
    // these tests are failed because NSNumber internally stores INFINITY as a double despite of numberWithFloat:
    //    XCTAssertEqualObjects([DSFLOAT(INFINITY) ds_cborEncodedObject], DATABYTES(0xfa, 0x7f, 0x80, 0x00, 0x00));
    //    XCTAssertEqualObjects([DSFLOAT(-INFINITY) ds_cborEncodedObject], DATABYTES(0xfa, 0xff, 0x80, 0x00, 0x00));
    //    XCTAssertEqualObjects([DSFLOAT(NAN) ds_cborEncodedObject], DATABYTES(0xfa,0x7f, 0xc0, 0x00, 0x00));
    // and following tests should NOT work basically:
    XCTAssertEqualObjects([DSDOUBLE(INFINITY) ds_cborEncodedObject], [DSFLOAT(INFINITY) ds_cborEncodedObject]);
    XCTAssertEqualObjects([DSDOUBLE(-INFINITY) ds_cborEncodedObject], [DSFLOAT(-INFINITY) ds_cborEncodedObject]);
    XCTAssertEqualObjects([DSDOUBLE(NAN) ds_cborEncodedObject], [DSFLOAT(NAN) ds_cborEncodedObject]);
}

- (void)testEncodeArrays {
    XCTAssertEqualObjects([@[] ds_cborEncodedObject], DATABYTES(0x80));
    NSArray *a = @[@1, @2, @3];
    XCTAssertEqualObjects([a ds_cborEncodedObject], DATABYTES(0x83, 0x01, 0x02, 0x03));
    
    a = @[ @[ @1 ], @[ @2, @3 ], @[ @4, @5 ] ];
    XCTAssertEqualObjects([a ds_cborEncodedObject], DATABYTES(0x83, 0x81, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05));
    
    NSMutableArray *ma = [NSMutableArray array];
    for (NSInteger i = 1; i <= 25; i++) {
        [ma addObject:@(i)];
    }
    XCTAssertEqualObjects([ma ds_cborEncodedObject], DATABYTES(0x98,0x19,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x18,0x18,0x19));
}

- (void)testEncodeDictionaries {
    XCTAssertEqualObjects([@{} ds_cborEncodedObject], DATABYTES(0xa0));
    
    NSDictionary *d = @{ @"x": @2, @"y": @4 };
    NSData *encoded = [d ds_cborEncodedObject];
    XCTAssert([encoded isEqualToData:DATABYTES(0xa2, 0x61, 0x78, 0x02, 0x61, 0x79, 0x04)]);
    
    d = @{ @"a": @[ @1 ], @"b": @[ @2, @3 ] };
    encoded = [d ds_cborEncodedObject];
    XCTAssert([encoded isEqualToData:DATABYTES(0xa2, 0x61, 0x61, 0x81, 0x01, 0x61, 0x62, 0x82, 0x02, 0x03)]);
}

@end

