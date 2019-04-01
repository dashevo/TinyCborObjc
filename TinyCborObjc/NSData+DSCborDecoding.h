//
//  NSData+DSCborDecoding.h
//  Pods-TinyCborObjc_Tests
//
//  Created by Andrew Podkovyrin on 01/04/2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (DSCborDecoding)

- (nullable id)ds_decodeCbor;

@end

NS_ASSUME_NONNULL_END
