# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

inhibit_all_warnings!

target 'tryExplainRx' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'MJRefresh','3.1.16'
  pod 'IQKeyboardManagerSwift', '6.2.1'
  pod 'SnapKit', '4.2.0'
  pod 'AttributedTextView', '1.4.1'
  pod 'Kingfisher', '4.10.1'
  
  pod 'Then','2.4.0'
  pod 'Reusable','4.0.5'
  pod 'RxSwift','4.5.0'
  pod 'RxCocoa','4.5.0'
  pod 'NSObject+Rx','4.4.1'
  pod 'MoyaMapper','1.2.1'
  pod 'MoyaMapper/RxCache','1.2.1'
  pod 'RxDataSources','3.1.0'
  pod 'RxGesture','2.2.0'


end









post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['AttributedTextView'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
