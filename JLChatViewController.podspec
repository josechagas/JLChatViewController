#
# Be sure to run `pod lib lint JLChatViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JLChatViewController"
  s.version          = "1.0.7"
  s.summary          = "JLChatViewController is a messages UI library that makes easy a creation of a chat."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
#s.description      = <<-DESC "This is a simple and totally customizable UI Library in swift for ios thats helps you to create a chat"DESC

  s.homepage         = "https://github.com/josechagas/JLChatViewController"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "José Lucas" => "joselucas1994@yahoo.com.br" }
  s.source           = { :git => "https://github.com/josechagas/JLChatViewController.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Classes/*.swift'
  s.resource_bundles = {
'JLChatViewController' => ['Assets/**/*.{png,storyboard,xib}']
}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
