# ObjCCBOR

![CI Status](https://github.com/getditto/TinyCborObjc/workflows/CI/badge.svg?branch=master)

ObjCCBOR allows encoding and decoding Foundation-objects into/from CBOR
representation.

Supported types:
- `NSDictionary`
- `NSArray`
- `NSString`
- `NSNumber`
- `NSNull`
- `NSData`

## Usage

Encoding

``` objective-c
#import <ObjCCBOR/ObjCCBOR.h>

NSDictionary *dictionary = ...;
NSError *error = nil;
NSData *cborData = [ObjCCBOR encode:dictionary error:&error];
```

Decoding

``` objective-c
#import <ObjCCBOR/ObjCCBOR.h>

NSData *data = ...; // CBOR data
NSError *error = nil;
id decoded = [ObjCCBOR decode:data error:&error];
```

## Dependencies

`ObjCCBOR` is built on top of [tinycbor](https://github.com/intel/tinycbor)
which is integrated as [git subrepo](https://github.com/ingydotnet/git-subrepo).

## Authors

Andrew Podkovyrin, podkovyrin@gmail.com
Hamilton Chapman, hamchapman@gmail.com
Connor Power, connor@connorpower.com

## License

ObjCCBOR is available under the MIT license. See the LICENSE file for more info.
