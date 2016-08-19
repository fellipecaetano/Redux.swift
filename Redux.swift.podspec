Pod::Spec.new do |s|
  s.name = 'Redux.swift'
  s.module_name = 'Redux'
  s.version = '0.4.0'
  s.summary = 'An implementation of a predictable state container in Swift.'
  s.description = <<-DESC
Redux.swift is an implementation of a predictable state container, written in Swift. It aims to enforce separation of concerns and a unidirectional data flow by keeping your entire app state in a single data structure that cannot be mutated directly, instead relying on an action dispatch mechanism to describe changes.
                     DESC
  s.homepage = 'https://github.com/fellipecaetano/Redux.swift'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Fellipe Caetano' => 'fellipe.caetano4@gmail.com' }
  s.source = { :git => 'https://github.com/fellipecaetano/Redux.swift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.requires_arc = true
  s.subspec 'Standard' do |ss|
    ss.source_files = ['Redux.swift/Classes/**/*']
    ss.exclude_files = ['Redux.swift/Classes/RxSwift/**/*']
  end
  s.subspec 'RxSwift' do |ss|
    ss.source_files = ['Redux.swift/Classes/**/*']
    ss.dependency 'RxSwift', '~> 2.6'
  end
  s.default_subspec = 'Standard'
end
