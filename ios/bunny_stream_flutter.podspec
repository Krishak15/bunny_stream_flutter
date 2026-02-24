#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint bunny_stream_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'bunny_stream_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Bunny Stream Flutter plugin for iOS.'
  s.description      = <<-DESC
Bunny Stream Flutter plugin for iOS.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'anandevu2@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'bunny_stream_flutter/Sources/bunny_stream_flutter/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.6'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'bunny_stream_flutter_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
