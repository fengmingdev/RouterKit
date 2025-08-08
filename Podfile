# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
platform :osx, '11.0'
platform :tvos, '14.0'
platform :watchos, '7.0'

target 'RouterKit_Example' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RouterKit_Example
  pod 'RouterKit', :path => '.', :modular_headers => true

  target 'RouterKit_Tests' do
    inherit! :search_paths
    # Pods for testing
    pod 'XCTest-Gherkin', '~> 2.0'
  end
end

# 支持静态库
target 'RouterKit_Static_Example' do
  use_frameworks! :linkage => :static
  pod 'RouterKit', :path => '.', :modular_headers => true
end