platform :ios, '16.6'

target 'GetKart' do
  use_frameworks!

  pod 'GoogleSignIn'
  pod 'GoogleSignInSwiftSupport'
  pod 'Alamofire'
  pod 'Kingfisher', '~> 7.0'
  pod "MMMaterialDesignSpinner"
  pod 'Firebase/Messaging'
  pod 'FirebaseCore'
  pod 'FirebaseAuth'
  pod 'FittedSheets'
  pod 'Socket.IO-Client-Swift', '~> 16.0'
  pod 'GooglePlaces'
  pod 'SwiftyGif'
  pod 'IQKeyboardManagerSwift'
  pod 'RealmSwift', '10.54.2'
  pod 'SVGKit'
  pod 'PhonePePayment'
  pod 'Mantis'
  pod 'NSFWDetector'
  pod 'MarqueeLabel'
  pod 'PayUIndia-CheckoutPro'

  target 'GetKartTests' do
    inherit! :search_paths
  end

  target 'GetKartUITests' do
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.6'
    end
  end
end
