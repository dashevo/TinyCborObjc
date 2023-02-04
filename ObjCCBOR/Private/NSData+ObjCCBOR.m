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

#import "NSData+ObjCCBOR.h"
#import "cbortojson_nsstring.h"

#import <tinycbor/cbor.h>

NSString *const ObjCCBORDecodingErrorDomain = @"live.ditto.objccbor.decoding-error";

NS_ASSUME_NONNULL_BEGIN

@implementation NSData (DSCborDecoding)

- (nullable id)ds_decodeCborError:(NSError *_Nullable __autoreleasing *)error {
    if (self.length == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:ObjCCBORDecodingErrorDomain
                                         code:CborErrorUnknownLength
                                     userInfo:nil];
        }

        return nil;
    }

    uint8_t *inBuffer = (uint8_t *)self.bytes;
    size_t inBufferLen = self.length;

    NSMutableString *jsonString = [NSMutableString string];

    CborParser parser;
    CborValue value;
    const int flags = 0;
    CborError err = cbor_parser_init(inBuffer, inBufferLen, 0, &parser, &value);
    if (err == CborNoError) {
        err = cbor_value_to_json_advance_nsstring(jsonString, &value, flags);
    }

    if (err != CborNoError) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:ObjCCBORDecodingErrorDomain
                                         code:err
                                     userInfo:nil];
        }

        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments
                                                      error:&jsonError];

    return convertBase64DataToNSData(jsonObject);
}

#pragma mark - Private

static id convertBase64DataToNSData(id object) {
    NSString* const string = [object isKindOfClass:NSString.class] ? object : nil;
    if (string != nil && [string hasPrefix:DSCborBase64DataMarker]) {
        return dataFromBase64EncodedStringWithMarker(string);
    }

    NSMutableArray *const mutableArray = [object isKindOfClass:NSMutableArray.class] ? object : nil;
    if (mutableArray != nil) {
        NSInteger const count = mutableArray.count;
        for (NSInteger i = 0; i < count; i += 1) {
            @autoreleasepool {
                id const element = mutableArray[i];
                id const elementConverted = convertBase64DataToNSData(element);
                if (elementConverted != element) {
                    mutableArray[i] = element;
                }
            }
        }
        return mutableArray;
    }

    NSMutableDictionary *const mutableDictionary = [object isKindOfClass:NSMutableDictionary.class] ? object : nil;
    if (mutableDictionary != nil) {
        for (id const key in mutableDictionary.allKeys) {
            @autoreleasepool {
                id const value = mutableDictionary[key];
                id const valueConverted = convertBase64DataToNSData(value);
                if (valueConverted != value) {
                    mutableDictionary[key] = valueConverted;
                }
            }
        }
    }

    // Nothing to do, rteturn object as-is.
    return object;
}

static id dataFromBase64EncodedStringWithMarker(NSString *string) {
    NSRange const markerRange = [string rangeOfString:DSCborBase64DataMarker];
    if (markerRange.location == NSNotFound) {
        [NSException raise:NSInternalInconsistencyException format:@"Internal inconsistency, can't convert base64 string to `NSData`, `DSCborBase64DataMarker` not found: %@", string];
    }

    NSString *const base64String = [string substringFromIndex:markerRange.length];
    NSData *const data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];

    if (!data) {
        [NSException raise:NSInternalInconsistencyException format:@"Internal inconsistency, can't convert base64 string to `NSData`, string is not valid base64 encoded data: %@", string];
    }

    return data;
}

@end

NS_ASSUME_NONNULL_END
