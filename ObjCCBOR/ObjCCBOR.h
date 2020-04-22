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

+ (nullable id)decode:(NSData *)data error:(NSError * _Nullable __autoreleasing *)error;
+ (NSData *)encode:(NSObject *)object error:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
