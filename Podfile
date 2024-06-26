platform :ios, '14.0'


target 'AVDorisTestPlayer' do
  use_frameworks!
  pod 'VesperSDK', :path => '../vesper-sdk-apple/'
  pod 'dice-shield-ios', :git => 'git@github.com:DiceTechnology/dice-shield-ios.git', :tag => '2.0.15'
  pod 'AVDoris', :path => '../avdoris/'
  pod 'AVDoris/UI', :path => '../avdoris/'
  pod 'AVDoris/Plugins', :path => '../avdoris/'
  pod 'DeviceKit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      cflags = config.build_settings['OTHER_CFLAGS'] || ['$(inherited)']
      cflags << '-fembed-bitcode'
      config.build_settings['OTHER_CFLAGS'] = cflags
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      config.build_settings["EXCLUDED_ARCHS[sdk=appletvsimulator*]"] = "arm64"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
