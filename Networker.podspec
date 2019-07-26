Pod::Spec.new do |spec|
  spec.name         = "Networker"
  spec.version      = "0.2.3"
  spec.summary      = "Swifty networking."
  spec.description  = <<-DESC
  Type-safe, API-agnostic networking.
                   DESC
  spec.homepage     = "https://github.com/shapedbyiris/networker"
  spec.source = { :git => 'https://github.com/shapedbyiris/networker.git', :tag => spec.version }
  spec.license      = {
    :type => 'Custom',
    :text => 'Permission is hereby granted ...'
  }
  spec.author       = { "Ariel Elkin" => "ariel@shapedbyiris.com" }
  spec.platform     = :ios, :macos
  spec.ios.deployment_target = "10.0"
  spec.osx.deployment_target = "10.9"
  spec.swift_version = '5.0'
  spec.source_files  = "Sources/*.swift"

  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = "Tests/*.swift"
  end
end
