use_frameworks!
inhibit_all_warnings!

def shared_pods
    pod 'DiningStack', :git => 'https://github.com/cuappdev/DiningStack.git'
end

target 'Eatery' do
    platform :ios, '9.0'

    pod 'SwiftyJSON'
    pod 'SnapKit'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'FLEX', '~> 2.0', :configurations => ['Debug']
    pod 'Hero'
    pod 'ARCL'
    pod 'Kingfisher'
    pod 'NVActivityIndicatorView'
    pod 'Apollo'
end

target 'Eatery Watch App' do
    platform :watchos, '2.0'
    shared_pods
end

target 'Eatery Watch App Extension' do
    platform :watchos, '2.0'
    shared_pods
end
