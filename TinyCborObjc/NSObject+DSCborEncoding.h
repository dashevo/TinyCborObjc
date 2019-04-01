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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const DSTinyCborEncodingErrorDomain;

@interface NSData (DSCborEncodingHelper)


/**
 HEX string representation of NSData object
 */
- (NSString *)ds_hexStringFromData;

@end

@interface NSObject (DSCborEncoding)

/**
 Encode object into CBOR representation.
 Supports encoding of NSDictionary, NSArray, NSNumber, NSString, NSNull.

 @return NSData with uint8_t bytes array or nil if encoding fails
 */
- (nullable NSData *)ds_cborEncodedObject;

/**
 Encode object into CBOR representation.
 Supports encoding of NSDictionary, NSArray, NSNumber, NSString, NSNull.

 @param error Encoding error description
 @return NSData with uint8_t bytes array or nil if encoding fails
 */
- (nullable NSData *)ds_cborEncodedObjectError:(NSError *__autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
