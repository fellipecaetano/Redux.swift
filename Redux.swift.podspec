Pod::Spec.new do |s|
  s.name             = 'Redux.swift'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Redux.swift.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/Redux.swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Fellipe Caetano' => 'fellipe.caetano4@gmail.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/Redux.swift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Redux.swift/Source/**/*'
end
