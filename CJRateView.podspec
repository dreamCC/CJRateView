
Pod::Spec.new do |s|

  s.name         = "CJRateView"
  s.version      = "1.0.0"
  s.summary      = "A short description of CJRateView."
  s.homepage     = "https://github.com/dreamCC/CJRateView"

  s.license      = "MIT"

  s.author       = { "仁和Mac" => "376811578@qq.com" }

  s.platform     = :ios, "8.0"


  s.source       = { :git => "https://github.com/dreamCC/CJRateView.git", :tag => s.version }


  s.source_files  = "CJRateView/*.{h,m}"


  s.resource  = "CJRateView/CJRateView.bundle"
  s.requires_arc = true

end
