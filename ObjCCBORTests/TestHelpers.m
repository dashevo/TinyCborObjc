//
//  TestHelpers.m
//  ObjCCBORTests
//
//  Created by Hamilton Chapman on 30/04/2020.
//  Copyright © 2020 Dash. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TestsHelpers.h"

@implementation MyCBORCompatibleObject

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self != nil) {
        _name = name;
    }
    return self;
}

- (NSDictionary<NSString *, id> *)CBORRepresentation {
    return @{@"the_name": self.name};
}

@end
