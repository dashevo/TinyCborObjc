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
                                                    options:kNilOptions
                                                      error:&jsonError];
    if (jsonError != nil && error != NULL) {
        *error = jsonError;
    }

    return parsedData;
}

@end

NS_ASSUME_NONNULL_END
