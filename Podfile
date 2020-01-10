use_frameworks!
inhibit_all_warnings!

def shared_pods
    pod 'Apollo', :git => 'https://github.com/apollographql/apollo-ios.git'
    pod 'SwiftyJSON'
end

target 'Eatery' do
    platform :ios, '11.0'
    shared_pods

    pod 'ARCL'
    pod 'FLEX', '~> 2.0', :configurations => ['Debug']
    pod 'Fabric'
    pod 'Firebase/Analytics'
    pod 'Hero'
    pod 'Kingfisher'
    pod 'NVActivityIndicatorView'
    pod 'SnapKit'
    pod 'CHIPageControl/Jaloro'
    pod 'lottie-ios'
end

target 'Eatery Watch App' do
    platform :watchos, '6.0'
    shared_pods
end

target 'Eatery Watch App Extension' do
    platform :watchos, '6.0'
    shared_pods
    pod 'SDWebImageSwiftUI'
end
