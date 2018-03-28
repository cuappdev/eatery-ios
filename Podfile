use_frameworks!

def shared_pods
  pod 'DiningStack', :git => 'https://github.com/cuappdev/DiningStack.git'
end

target 'Eatery' do
  platform :ios, '9.0'

  pod 'SwiftyJSON'
  pod 'SnapKit'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Hero'
  pod 'ARCL'
  pod 'Kingfisher'
  pod 'NVActivityIndicatorView'
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
