use_frameworks!
inhibit_all_warnings!

def shared_pods
    pod 'Apollo', :git => 'https://github.com/apollographql/apollo-ios.git'
    pod 'SwiftyJSON'
    pod 'SwiftyUserDefaults'
end

target 'Eatery' do
    platform :ios, '11.0'
    shared_pods

    pod 'AppDevAnnouncements', :git => 'https://github.com/cuappdev/appdev-announcements.git', :commit => '4cfbcd46af092037ac6632fe5616a13e5f280615'
    pod 'ARCL'
    pod 'BulletinBoard'
    pod 'CHIPageControl/Jaloro'
    pod 'FLEX', '~> 2.0', :configurations => ['Debug']
    pod 'Fabric'
    pod 'Firebase/Analytics'
    pod 'Hero'
    pod 'Kingfisher'
    pod 'NVActivityIndicatorView'
    pod 'SnapKit'
    pod 'lottie-ios'
    pod 'Wormholy', :configurations => ['Debug', 'TestFlight']
end

target 'Eatery Watch App' do
    platform :watchos, '6.0'
    shared_pods
end

target 'Eatery Watch App Extension' do
    platform :watchos, '6.0'
    shared_pods
end

# https://stackoverflow.com/questions/63607158/xcode-12-building-for-ios-simulator-but-linking-in-object-file-built-for-ios
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
