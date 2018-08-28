#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "cbor.h"
#import "cborinternal_p.h"
#import "cborjson.h"
#import "compilersupport_p.h"
#import "tinycbor-version.h"
#import "utf8_p.h"

FOUNDATION_EXPORT double tinycborVersionNumber;
FOUNDATION_EXPORT const unsigned char tinycborVersionString[];

