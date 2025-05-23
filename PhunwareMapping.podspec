Pod::Spec.new do |spec|
  spec.name                = 'PhunwareMapping'
  spec.version             = '1.9.2'
  spec.summary             = 'A Phunware module that provides mapping and routing functionalities.'
  spec.homepage            = 'https://www.phunware.com'
  spec.license             = { :type => 'Copyright', :text => 'Copyright 2009-present Phunware, Inc. All rights reserved.' }
  spec.author              = { 'Phunware, Inc.' => 'https://www.phunware.com' }
  spec.social_media_url    = 'https://twitter.com/Phunware'
  spec.platform            = :ios, '15.5'
  spec.source              = { :git => 'https://github.com/phunware/maas-mapping-module-ios.git', :tag => spec.version.to_s }
  spec.vendored_frameworks = 'Frameworks/PhunwareMapping.xcframework'
  spec.framework           = 'UIKit'
  spec.cocoapods_version   = '>= 1.15.2'

  spec.dependency 'PhunwareFoundation', '~> 1.1.0'
  spec.dependency 'PhunwareNetworking', '~> 1.3.0'
  spec.dependency 'PhunwareTheming', '~> 1.1.0'
  spec.dependency 'PhunwarePermissionPriming/Location', '~> 1.5.0'
  spec.dependency 'PWMapKit', '~> 3.16.1'
end
