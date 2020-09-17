Pod::Spec.new do |s|
  s.name         = "THEPageControl"
  s.version      = "1.2.0"
  s.summary      = "Simple and flexible page control"
  s.description  = <<-DESC
                   Simple to use page control written in Swift. Provides full customization per dot.
                   Includes automatic intermediate state resolution for smooth transitions.
                   DESC
  s.homepage     = "https://github.com/badoo/THEPageControl"
  s.screenshots  = "https://raw.githubusercontent.com/badoo/THEPageControl/master/readme_images/example.gif"
  s.license      = { :type => "MIT" }
  s.authors      = { "Igor Kashkuta" => "ikashkuta@gmail.com" }
  s.platform     = :ios, "12.0"
  s.source       = { :path => "./" }
  s.source       = { :git => "https://github.com/badoo/THEPageControl.git", :tag => "#{s.version}" }
  s.source_files = "THEPageControl/Source/**/*.{h,m,swift}"
  s.public_header_files = "THEPageControl/Source/**/*.h"
  s.requires_arc = true
end
