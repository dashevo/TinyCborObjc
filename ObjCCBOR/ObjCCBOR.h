//
//  ObjCCBOR.h
//  ObjCCBOR
//
//  Created by Hamilton Chapman on 20/02/2020.
//  Copyright © 2020 Ditto. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjCCBOR : NSObject

/**
 Decode CBOR data into its corresponding NSObject type. Note that
 this library supports primitives so the resulting type could be any
 of `NSDictionary`, `NSArray`, `NSString`, `NSNumber`, `NSNull` or
 `NSData`.

 @param data The data to be decoded.
 @param error An optional error out parameter. If not `NULL`, then
 an error object will be written to this parameter should decoding fail.
 @returns Returns one of `NSDictionary`, `NSArray`, `NSString`,
 `NSNumber`, `NSNull` or `NSData`. Will return `nil` if the decoding
 fails.
 */
+ (nullable id)decode:(NSData *)data error:(NSError * _Nullable __autoreleasing *)error;

/**
 Encodes an NSObject into its CBOR representation. Note that `object`
 may only be one of `NSDictionary`, `NSArray`, `NSString`, `NSNumber`,
 `NSNull`, `NSData` or their mutable variants where appropriate.

 @param object The object to be encoded.
 @param error An optional error out parameter. If not `NULL`, then
 an error object will be written to this parameter should encoding fail.
 @returns Returns the encoded data or `nil` if the encoding fails.
 */
+ (NSData *)encode:(NSObject *)object error:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
