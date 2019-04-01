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
#import <tinycbor/cborjson.h>

#import "fmemopen.h"

NSString *const DSTinyCborDecodingErrorDomain = @"org.dash.tinycbor.decoding-error";

NS_ASSUME_NONNULL_BEGIN

@implementation NSData (DSCborDecoding)

- (nullable id)ds_decodeCborWithOutBufferSize:(size_t)outBufferSize
                                        error:(NSError *_Nullable __autoreleasing *)error {
    if (self.length == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:DSTinyCborDecodingErrorDomain
                                         code:CborErrorUnknownLength
                                     userInfo:nil];
        }

        return nil;
    }

    const size_t elementSize = sizeof(uint8_t);

    uint8_t *inBuffer = (uint8_t *)self.bytes;
    size_t inBufferLen = sizeof(inBuffer) / elementSize;

    size_t outBufferLen = outBufferSize / elementSize;
    uint8_t *outBuffer = calloc(outBufferLen, elementSize);
    FILE *file;
    if (@available(iOS 11.0, *)) {
        file = fmemopen(outBuffer, outBufferLen, "w");
    }
    else {
        file = fmemopen_compatible(outBuffer, outBufferLen, "w");
    }

    CborParser parser;
    CborValue value;
    const int flags = CborConvertDefaultFlags;
    CborError err = cbor_parser_init(inBuffer, inBufferLen, 0, &parser, &value);
    if (err == CborNoError) {
        err = cbor_value_to_json_advance(file, &value, flags);
    }

    if (err != CborNoError) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:DSTinyCborDecodingErrorDomain
                                         code:err
                                     userInfo:nil];
        }

        fclose(file);

        return nil;
    }

    // convert to NSString first to automatically process null-terminated sequence
    NSString *jsonString = [NSString stringWithUTF8String:(char *)outBuffer];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError = nil;
    id parsedData = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:kNilOptions
                                                      error:&jsonError];
    if (jsonError != nil && error != NULL) {
        *error = jsonError;
    }

    fclose(file);

    return parsedData;
}

@end

NS_ASSUME_NONNULL_END
