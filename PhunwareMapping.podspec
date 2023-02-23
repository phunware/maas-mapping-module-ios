Pod::Spec.new do |spec|

  spec.name                = "PhunwareMapping"
  spec.version             = "1.7.0"
  spec.summary             = "A Phunware module that provides mapping and routing functionalities."
  spec.homepage            = "https://www.phunware.com"
  spec.license             = { :type => "Copyright", :text => "Copyright 2009-present Phunware, Inc. All rights reserved." }
  spec.author              = { "Phunware, Inc." => "https://www.phunware.com" }
  spec.social_media_url    = "https://twitter.com/Phunware"
  spec.platform            = :ios, "13.0"
  spec.source              = { :git => "https://github.com/phunware/maas-mapping-module-ios.git", :tag => spec.version.to_s }
  spec.vendored_frameworks = "Frameworks/PhunwareMapping.xcframework"
  spec.framework           = "UIKit"
  
  spec.dependency 'PhunwareFoundation', '~> 1.0.0'
  spec.dependency 'PhunwareNetworking', '~> 1.1.0'
  spec.dependency 'PhunwareTheming', '~> 1.0.2'
  spec.dependency 'PhunwarePermissionPriming', '~> 1.2.1'
  spec.dependency 'PWMapKit', '~> 3.15.0'
  
end
