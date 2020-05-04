//
//  TestsHelpers.h
//  ObjCCBOR
//
//  Created by Andrew Podkovyrin on 01/04/2019.
//  Copyright © 2019 Andrew Podkovyrin. All rights reserved.
//

#import <ObjCCBOR/CBORRepresentable.h>

#ifndef TestsHelpers_h
#define TestsHelpers_h

#define DATABYTES(...) ({ \
uint8_t buffer[] = {__VA_ARGS__}; \
NSData *data = [NSData dataWithBytes:buffer length:sizeof(buffer) / sizeof(uint8_t)]; \
data; \
})\

#define DSFLOAT(A) [NSNumber numberWithFloat:A]
#define DSDOUBLE(A) [NSNumber numberWithDouble:A]

@interface MyCBORCompatibleObject : NSObject <CBORRepresentable>
- (instancetype)initWithName:(NSString *)name;
@property (nonatomic, readonly) NSString *name;
@end

#endif /* TestsHelpers_h */
