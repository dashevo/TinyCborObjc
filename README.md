# TinyCborObjc

[![CI Status](https://img.shields.io/travis/dashevo/TinyCborObjc.svg?style=flat)](https://travis-ci.org/dashevo/TinyCborObjc)
[![Version](https://img.shields.io/cocoapods/v/TinyCborObjc.svg?style=flat)](https://cocoapods.org/pods/TinyCborObjc)
[![License](https://img.shields.io/cocoapods/l/TinyCborObjc.svg?style=flat)](https://cocoapods.org/pods/TinyCborObjc)
[![Platform](https://img.shields.io/cocoapods/p/TinyCborObjc.svg?style=flat)](https://cocoapods.org/pods/TinyCborObjc)

TinyCborObjc allows encoding and decoding Foundation-objects into/from CBOR representation.

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
#import <TinyCborObjc/NSObject+DSCborEncoding.h>

NSDictionary *dictionary = ...;
NSData *cborData = [dictionary ds_cborEncodedObject];
```

Decoding
``` objective-c
#import <TinyCborObjc/NSData+DSCborDecoding.h>

NSData *data = ...; // CBOR data
NSError *error = nil;
id decoded = [data ds_decodeCborError:&error];
```

## Dependencies

Build on top of [tinycbor](https://github.com/intel/tinycbor) library (integrated as pod dependency).

## Installation

TinyCborObjc is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TinyCborObjc'
```

## Author

Andrew Podkovyrin, podkovyrin@gmail.com

## License

TinyCborObjc is available under the MIT license. See the LICENSE file for more info.
