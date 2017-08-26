use_frameworks!

def shared_pods
  pod 'DiningStack', :git => 'https://github.com/cuappdev/DiningStack.git'
end

target 'Eatery' do
  platform :ios, '9.0'
  pod 'SwiftyJSON'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Hero'
  pod 'Kingfisher'
  shared_pods
end

target 'Eatery Watch App' do
  platform :watchos, '2.0'
  shared_pods
end

target 'Eatery Watch App Extension' do
  platform :watchos, '2.0'
  shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
