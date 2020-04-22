//
//  ObjCCBOR.m
//  ObjCCBOR
//
//  Created by Hamilton Chapman on 20/02/2020.
//  Copyright © 2020 Ditto. All rights reserved.
//

#import "ObjCCBOR.h"
#import "NSData+ObjCCBOR.h"
#import "NSObject+ObjCCBOR.h"

@implementation ObjCCBOR

+ (nullable id)decode:(NSData *)data error:(NSError * _Nullable __autoreleasing *)error {
    NSError *err = nil;
    id decoded = [data ds_decodeCborError:&err];
    if (error && err != nil) {
        *error = err;
    }
    return decoded;
}

+ (NSData *)encode:(NSObject *)object error:(NSError * _Nullable __autoreleasing *)error {
    NSError *err = nil;
    NSData *encoded = [object ds_cborEncodedObjectError:&err];
    if (error && err != nil) {
        *error = err;
    }
    return encoded;
}

@end
