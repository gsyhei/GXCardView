#
#  Be sure to run `pod spec lint GXCardView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "GXCardView"
  s.version      = "0.0.8"
  s.summary      = "一个卡片式布局，类似（探探附近/QQ颜值匹配）等..."
  s.homepage     = "https://github.com/gsyhei/GXCardView"
  s.license      = "MIT"
  s.author       = { "Gin" => "279694479@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/gsyhei/GXCardView.git", :tag => "0.0.8" }
  s.requires_arc = true
  s.source_files = "GXCardView/GXCardView*.{h,m}"
  s.frameworks   = "Foundation","UIKit"

end
