use_frameworks!
inhibit_all_warnings!

def shared_pods
    pod 'DiningStack', :git => 'https://github.com/cuappdev/DiningStack.git'
end

target 'Eatery' do
    platform :ios, '11.0'

    pod 'ARCL'
    pod 'Apollo', :git => 'https://github.com/apollographql/apollo-ios.git'
    pod 'AppDevAnalytics', :git => 'https://github.com/cuappdev/ios-analytics.git'
    pod 'Crashlytics'
    pod 'FLEX', '~> 2.0', :configurations => ['Debug']
    pod 'Fabric'
    pod 'Firebase/Analytics'
    pod 'Hero'
    pod 'Kingfisher'
    pod 'NVActivityIndicatorView'
    pod 'SnapKit'
    pod 'SwiftyJSON'
end

target 'Eatery Watch App' do
    platform :watchos, '4.0'
    shared_pods
end

target 'Eatery Watch App Extension' do
    platform :watchos, '4.0'
    shared_pods
end
