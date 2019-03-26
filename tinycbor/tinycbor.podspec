#
# pod spec lint tinycbor.podspec --no-clean --verbose --allow-warnings
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'tinycbor'
  s.version          = '0.5.3-alpha2'
  s.summary          = 'Concise Binary Object Representation (CBOR) Library'
  s.description      = <<-DESC
The TinyCBOR library is a small CBOR encoder and decoder library, optimized for very fast operation with very small footprint. The main encoder and decoder functions do not allocate memory.

TinyCBOR is divided into the following groups of functions and structures:

Global constants
Encoding to CBOR
Parsing CBOR streams
Converting CBOR to text
Converting CBOR to JSON
                       DESC

  s.homepage         = 'https://github.com/intel/tinycbor/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Intel Corporation' => 'webmaster@linux.intel.com' }
  s.source           = { :git => 'https://github.com/intel/tinycbor.git', :commit => 'd94ca09aa91f5b3c581527aa8bca179a82b79874' }

  s.ios.deployment_target = '9.0'

  s.source_files = 'src/*.{h,c}'

  s.pod_target_xcconfig = {
    'CLANG_WARN_DOCUMENTATION_COMMENTS' => 'NO',
    'CLANG_WARN_UNREACHABLE_CODE' => 'NO',
    'GCC_WARN_UNINITIALIZED_AUTOS' => 'NO',
    'GCC_WARN_64_TO_32_BIT_CONVERSION' => 'NO',
    'GCC_WARN_INHIBIT_ALL_WARNINGS' => 'YES'
  }

end