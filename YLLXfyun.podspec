
Pod::Spec.new do |s|


  s.name         = "YLLXfyun"
  s.version      = "0.0.2"
  s.summary      = "A short description of YLLXfyun."

  s.description  = "xunfei"

  s.homepage     = "https://github.com/yuliang6/YLLXfyun"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "yuliangliang" => "yuliang1345@163.com" }

   s.ios.deployment_target = "7.0"
   s.source       = { :git => "https://github.com/yuliang6/YLLXfyun.git", :tag => "#{s.version}" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # s.resource  = "icon.png"
   #s.resources = "Assets/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


 s.frameworks = 'AVFoundation','SystemConfiguration','Foundation','CoreTelephony','AudioToolbox','UIKit','CoreLocation','AddressBook','QuartzCore','CoreGraphics'

 s.libraries    = 'z'
 s.vendored_frameworks = 'Assets/iflyMSC.framework'

  # s.requires_arc = true

  # s.dependency "JSONKit", "~> 1.4"

end
