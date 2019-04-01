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

- (void)testSimpleDecoding {
    NSData *data = DATABYTES(0x82, 0x01, 0x02);
    NSArray *decoded = [data ds_decodeCbor];
}


@end
