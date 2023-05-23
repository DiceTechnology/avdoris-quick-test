platform :ios, '12.0'

target 'AVDorisTestPlayer' do
  use_frameworks!

  pod 'AVDoris', "= 1.9.8"
  pod 'google-cast-sdk', "= 4.7.0"
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
