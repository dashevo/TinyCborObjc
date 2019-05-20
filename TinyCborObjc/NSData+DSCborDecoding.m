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

#import "NSData+DSCborDecoding.h"

#import <tinycbor/cbor.h>

#import "cbortojson_nsstring.h"

NSString *const DSTinyCborDecodingErrorDomain = @"org.dash.tinycbor.decoding-error";

NS_ASSUME_NONNULL_BEGIN

@implementation NSData (DSCborDecoding)

- (nullable id)ds_decodeCborError:(NSError *_Nullable __autoreleasing *)error {
    if (self.length == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:DSTinyCborDecodingErrorDomain
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
            *error = [NSError errorWithDomain:DSTinyCborDecodingErrorDomain
                                         code:err
                                     userInfo:nil];
        }

        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError = nil;
    id parsedData = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&jsonError];
    [self convertBase64DataToNSData:parsedData];
    if (jsonError != nil && error != NULL) {
        *error = jsonError;
    }

    return parsedData;
}

#pragma mark - Private

- (void)convertBase64DataToNSData:(id)object {
    if ([object isKindOfClass:NSMutableArray.class]) {
        NSMutableArray *mutableArray = (NSMutableArray *)object;
        for (NSUInteger i = 0; i < mutableArray.count; i++) {
            id element = mutableArray[i];
            if ([element isKindOfClass:NSArray.class] ||
                [element isKindOfClass:NSDictionary.class]) {
                [self convertBase64DataToNSData:element];
            }
            else if ([self shouldConvertObject:element]) {
                id converted = [self dataFromBase64EncodedStringWithMarker:element];
                [mutableArray replaceObjectAtIndex:i withObject:converted];
            }
        }
    }
    else if ([object isKindOfClass:NSMutableDictionary.class]) {
        NSMutableDictionary *mutableDicitonary = (NSMutableDictionary *)object;
        for (id key in mutableDicitonary.allKeys) {
            id value = mutableDicitonary[key];
            if ([value isKindOfClass:NSArray.class] ||
                [value isKindOfClass:NSDictionary.class]) {
                [self convertBase64DataToNSData:value];
            }
            else if ([self shouldConvertObject:value]) {
                id converted = [self dataFromBase64EncodedStringWithMarker:value];
                mutableDicitonary[key] = converted;
            }
        }
    }
}

- (id)dataFromBase64EncodedStringWithMarker:(NSString *)string {
    NSRange markerRange = [string rangeOfString:DSCborBase64DataMarker];
    NSAssert(markerRange.location != NSNotFound, @"String is not valid for conversion");
    if (markerRange.location == NSNotFound) {
        return string;
    }
    NSString *base64String = [string substringFromIndex:markerRange.length];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String
                                                       options:kNilOptions];
    if (!data) {
        return string;
    }
    
    return data;
}

- (BOOL)shouldConvertObject:(id)object {
    if ([object isKindOfClass:NSString.class] &&
        [object hasPrefix:DSCborBase64DataMarker]) {
        
        return YES;
    }
    
    return NO;
}

@end

NS_ASSUME_NONNULL_END
