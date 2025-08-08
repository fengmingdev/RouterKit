Pod::Spec.new do |s|
  s.name         = 'RouterKit'
  s.version      = '1.0.0'
  s.summary      = 'A powerful, modular routing framework for iOS applications.'
  s.description  = <<-DESC
                   A powerful, modular routing framework for iOS applications with support for parameters, regex, and wildcards.
                   DESC
  s.homepage     = 'https://github.com/fengmingdev/RouterKit'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'fengmingdev' => 'fengmingdev@gmail.com' }
  s.platform     = :ios, '13.0'
  s.swift_version = '5.9'
  s.source       = { :git => 'https://github.com/fengmingdev/RouterKit.git', :tag => s.version.to_s }
  s.source_files = 'Sources/**/*.swift'
  s.resources    = 'Documentation/**/*.md'
end