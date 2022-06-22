//
//  CBORRepresentable.h
//  ObjCCBOR
//
//  Created by Hamilton Chapman on 30/04/2020.
//  Copyright © 2020 Dash. All rights reserved.
//

#import <ObjCCBOR/Mangling.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CBORRepresentable

- (nullable NSObject *)CBORRepresentation;

@end

NS_ASSUME_NONNULL_END
