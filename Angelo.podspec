#
# Be sure to run `pod lib lint Angelo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Angelo'
  s.version          = '0.1.0'
  s.summary          = 'Angelo is a procedural generation library written in Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Angelo is a procedural generation library written in Swift. It offers L-Systems, with extra possibilities of making the elements carry parameters and more flexibiltiy over which rules are executed.
                       DESC

  s.homepage         = 'https://github.com/enzomaruffa/Angelo'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Enzo Maruffa' => 'enzomm1999@gmail.com' }
  s.source           = { :git => 'https://github.com/enzomaruffa/Angelo.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.swift_version = ['5.0', '5.1', '5.2']

  s.source_files = 'Sources/Angelo/**/*.{swift}'
  
  # s.resource_bundles = {
  #   'Angelo' => ['Angelo/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
