Pod::Spec.new do |s|
  s.name             = 'TinyCborObjc'
  s.version          = '0.4.2'
  s.summary          = 'Objective-C wrapper for TinyCbor - Concise Binary Object Representation (CBOR) Library'

  s.description      = <<-DESC
TinyCborObjc allows encoding/decoding Foundation-objects into/from CBOR representation. Supports NSDictionary, NSArray, NSString, NSNumber and NSNull.
                       DESC

  s.homepage         = 'https://github.com/dashevo/TinyCborObjc'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrew Podkovyrin' => 'podkovyrin@gmail.com' }
  s.source           = { :git => 'https://github.com/dashevo/TinyCborObjc.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/podkovyr'

  s.ios.deployment_target = '9.0'

  s.source_files = 'TinyCborObjc/*.{h,m,c}'
  s.private_header_files = 'TinyCborObjc/cbortojson_nsstring.h'

  s.dependency 'tinycbor', '0.5.3-alpha3'

  s.pod_target_xcconfig = {
    'CLANG_WARN_DOCUMENTATION_COMMENTS' => 'NO',
    'GCC_WARN_64_TO_32_BIT_CONVERSION' => 'NO'
  }

end
