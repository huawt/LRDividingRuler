
Pod::Spec.new do |s|
  s.name             = 'LRDividingRuler'
  s.version          = '0.1.0'
  s.summary          = 'LRDividingRuler.'
  s.description      = 'LRDividingRuler'
  s.homepage         = 'https://github.com/huawt/LRDividingRuler'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huawt' => 'ghost263sky@163.com' }
  s.source           = { :git => 'https://github.com/huawt/LRDividingRuler.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.source_files = 'LRDividingRuler/Classes/**/*'
end
