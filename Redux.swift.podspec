Pod::Spec.new do |s|
  s.name = 'Redux.swift'
  s.module_name = 'Redux'
  s.version = '4.0.0'
  s.summary = 'An implementation of a predictable state container in Swift.'
  s.description = <<-DESC
Redux.swift is an implementation of a predictable state container, written in Swift. It aims to enforce separation of concerns and a unidirectional data flow by keeping your entire app state in a single data structure that cannot be mutated directly, instead relying on an action dispatch mechanism to describe changes.
                     DESC
  s.homepage = 'https://github.com/fellipecaetano/Redux.swift'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Fellipe Caetano' => 'fellipe.caetano4@gmail.com' }
  s.source = { :git => 'https://github.com/fellipecaetano/Redux.swift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.requires_arc = true

  s.subspec 'Basic' do |ss|
    ss.source_files = ['Source/**/*.swift']
    ss.exclude_files = ['Source/Rx/**/*.swift']
  end

  s.subspec 'Rx' do |ss|
    ss.source_files = ['Source/**/*.swift']
    ss.dependency 'RxSwift'
  end

  s.default_subspec = 'Basic'
end
