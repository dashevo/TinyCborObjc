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

#import "NSObject+DSCborEncoding.h"

#import <tinycbor/cbor.h>

NS_ASSUME_NONNULL_BEGIN

NSString *const DSCborEncodingTinyCborErrorDomain = @"org.dash.tinycbor.encoding-error";

static size_t const DSCborEncodingBufferChunkSize = 1024;

@implementation NSData (DSCborEncodingHelper)

- (NSString *)ds_hexStringFromData {
    const uint8_t *buffer = self.bytes;
    NSUInteger length = self.length;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:length * 2];
    for (NSUInteger i = 0; i < length; ++i) {
        [hexString appendFormat:@"%02lx", (unsigned long)buffer[i]];
    }

    return [NSString stringWithString:hexString];
}

@end

@implementation NSObject (DSCborEncoding)

- (nullable NSData *)ds_cborEncodedObject {
    return [self ds_cborEncodedObjectError:nil];
}

- (nullable NSData *)ds_cborEncodedObjectError:(NSError *__autoreleasing *)error {
    size_t bufferSize = DSCborEncodingBufferChunkSize;
    const size_t elementSize = sizeof(uint8_t);
    uint8_t *buffer = calloc(bufferSize / elementSize, elementSize);

    CborEncoder encoder;
    cbor_encoder_init(&encoder, buffer, bufferSize, 0);
    CborError err = [self ds_encodeObject:self intoBuffer:&buffer bufferSize:bufferSize encoder:&encoder];

    NSData *data = nil;
    if (err == CborNoError) {
        size_t actualBufferSize = cbor_encoder_get_buffer_size(&encoder, buffer);
        data = [[NSData alloc] initWithBytes:buffer length:actualBufferSize];
    }
    else {
        if (error != NULL) {
            *error = [NSError errorWithDomain:DSCborEncodingTinyCborErrorDomain
                                         code:err
                                     userInfo:nil];
        }
    }

    free(buffer);

    return data;
}

#pragma mark Private

- (CborError)ds_encodeObject:(id)object
                  intoBuffer:(uint8_t **)buffer
                  bufferSize:(size_t)bufferSize
                     encoder:(CborEncoder *)encoder {
    if ([object isKindOfClass:NSString.class]) {
        NSString *stringObject = (NSString *)object;
        return [self ds_performSafeEncodingIntoBuffer:buffer bufferSize:bufferSize encoder:encoder encodingBlock:^CborError {
            return cbor_encode_text_stringz(encoder, stringObject.UTF8String);
        }];
    }
    else if ([object isKindOfClass:NSNumber.class]) {
        NSNumber *numberObject = (NSNumber *)object;
        if ([numberObject isKindOfClass:@YES.class]) {
            return [self ds_performSafeEncodingIntoBuffer:buffer bufferSize:bufferSize encoder:encoder encodingBlock:^CborError {
                return cbor_encode_boolean(encoder, numberObject.boolValue);
            }];
        }
        else {
            CFNumberType numberType = CFNumberGetType((CFNumberRef)numberObject);
            switch (numberType) {
                case kCFNumberSInt8Type:
                case kCFNumberCharType: {
                    return [self ds_performSafeEncodingIntoBuffer:buffer bufferSize:bufferSize encoder:encoder encodingBlock:^CborError {
                        return cbor_encode_int(encoder, numberObject.charValue);
                    }];
                }
                case kCFNumberSInt16Type:
                case kCFNumberShortType: {
                    return [self ds_performSafeEncodingIntoBuffer:buffer bufferSize:bufferSize encoder:encoder encodingBlock:^CborError {
                        return cbor_encode_int(encoder, numberObject.shortValue);
                    }];
                }
                case kCFNumberSInt32Type:
                case kCFNumberIntType:
                case kCFNumberLongType:
                case kCFNumberNSIntegerType:
                case kCFNumberCFIndexType: {
                    return [self ds_performSafeEncodingIntoBuffer:buffer bufferSize:bufferSize encoder:encoder encodingBlock:^CborError {
                        return cbor_encode_int(encoder, numberObject.integerValue);
                    }];
                }
                case kCFNumberSInt64Type:
                case kCFNumberLongLongType: {
                    return [self ds_performSafeEncodingIntoBuffer:buffer bufferSize:bufferSize encoder:encoder encodingBlock:^CborError {
                        return cbor_encode_int(encoder, numberObject.longLongValue);
                    }];
                }
                case kCFNumberFloat32Type:
                case kCFNumberFloatType: {
                    return [self ds_performSafeEncodingIntoBuffer:buffer bufferSize:bufferSize encoder:encoder encodingBlock:^CborError {
                        return cbor_encode_float(encoder, numberObject.floatValue);
                    }];
                }
                case kCFNumberFloat64Type:
                case kCFNumberDoubleType:
                case kCFNumberCGFloatType: {
                    return [self ds_performSafeEncodingIntoBuffer:buffer bufferSize:bufferSize encoder:encoder encodingBlock:^CborError {
                        return cbor_encode_double(encoder, numberObject.doubleValue);
                    }];
                }
            }
        }
    }
    else if ([object isKindOfClass:NSNull.class]) {
        return [self ds_performSafeEncodingIntoBuffer:buffer bufferSize:bufferSize encoder:encoder encodingBlock:^CborError {
            return cbor_encode_null(encoder);
        }];
    }
    else if ([object isKindOfClass:NSArray.class]) {
        NSArray *arrayObject = (NSArray *)object;
        CborEncoder container;
        CborError err;

        err = cbor_encoder_create_array(encoder, &container, arrayObject.count);
        if (err != CborNoError) {
            return err;
        }
        for (id item in arrayObject) {
            err = [self ds_encodeObject:item intoBuffer:buffer bufferSize:bufferSize encoder:&container];
            if (err != CborNoError) {
                return err;
            }
        }
        return cbor_encoder_close_container(encoder, &container);
    }
    else if ([object isKindOfClass:NSDictionary.class]) {
        NSDictionary *dictionaryObject = (NSDictionary *)object;

        CborEncoder container;
        CborError err;
        err = cbor_encoder_create_map(encoder, &container, dictionaryObject.count);
        if (err != CborNoError) {
            return err;
        }
        NSMutableArray *sortedKeys = [dictionaryObject.allKeys mutableCopy];
        [sortedKeys sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
            NSString *obj1String = (NSString *)obj1;
            NSString *obj2String = (NSString *)obj2;
            NSData *data1 = [obj1String dataUsingEncoding:NSUTF8StringEncoding];
            NSData *data2 = [obj2String dataUsingEncoding:NSUTF8StringEncoding];
            NSString *hexString1 = [data1 ds_hexStringFromData];
            NSString *hexString2 = [data2 ds_hexStringFromData];
            if (obj1String.length < obj2String.length) {
                return NSOrderedAscending;
            }
            else if (obj1String.length > obj2String.length) {
                return NSOrderedDescending;
            }
            NSComparisonResult result = [hexString1 compare:hexString2];
            return result;
        }];
        for (id key in sortedKeys) {
            err = [self ds_encodeObject:key intoBuffer:buffer bufferSize:bufferSize encoder:&container];
            if (err != CborNoError) {
                return err;
            }

            id value = dictionaryObject[key];
            err = [self ds_encodeObject:value intoBuffer:buffer bufferSize:bufferSize encoder:&container];
            if (err != CborNoError) {
                return err;
            }
        }
        return cbor_encoder_close_container(encoder, &container);
    }
    else if ([object isKindOfClass:NSData.class]) {
        NSData *dataObject = (NSData *)object;
        return [self ds_performSafeEncodingIntoBuffer:buffer bufferSize:bufferSize encoder:encoder encodingBlock:^CborError {
            return cbor_encode_byte_string(encoder, dataObject.bytes, dataObject.length);
        }];
    }
    else {
        return CborErrorUnknownType;
    }
}

- (CborError)ds_performSafeEncodingIntoBuffer:(uint8_t **)buffer
                                   bufferSize:(size_t)bufferSize
                                      encoder:(CborEncoder *)encoder
                                encodingBlock:(CborError (^)(void))encodingBlock {
    CborError err = CborNoError;
    CborEncoder tmpencoder = *encoder;
    do {
        if (err == CborErrorOutOfMemory) {
            bufferSize += DSCborEncodingBufferChunkSize;
            uint8_t *newbuffer = realloc(*buffer, bufferSize);
            if (newbuffer == NULL) {
                return err;
            }

            // restore state
            *encoder = tmpencoder;
            encoder->data.ptr = newbuffer + (tmpencoder.data.ptr - *buffer);
            encoder->end = newbuffer + bufferSize;
            *buffer = newbuffer;
        }

        err = encodingBlock();

    } while (err == CborErrorOutOfMemory);

    return err;
}

@end

NS_ASSUME_NONNULL_END
