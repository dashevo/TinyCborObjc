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

## Embedding

When embedding this CBOR library within a distributed framework (or library),
there is a risk of running into symbol conflicts if the embedding binary or one
of its other dependencies also embed this CBOR library. All C symbols can be
hidden at link time of the final binary by adding `-Wl,-hidden-lObjCCBOR` to
`OTHER_LDFLAGS`.

However, Objective-C types must be unique per process. Therefore, this library
adds support for mangling all relevant types by generating a `Mangling.h` header
that defines macros that will prefix the original symbols with a custom build
setting `OBJC_CBOR_MANGLING_PREFIX`. This allows the source to use the original
ObjCCBOR type names, while renaming them behind the scenes at build time.

Typically, your final distribution binary is built by CI via `xcodebuild`, so
all you have to do is pass a unique mangling prefix like so:

``` command
xcodebuild build ... OBJC_CBOR_MANGLING_PREFIX=MyPersonalObjCCBORBuild123
```

## Authors

Andrew Podkovyrin, podkovyrin@gmail.com
Hamilton Chapman, hamchapman@gmail.com
Connor Power, connor@connorpower.com

## License

ObjCCBOR is available under the MIT license. See the LICENSE file for more info.
