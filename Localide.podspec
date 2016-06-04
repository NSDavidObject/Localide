Pod::Spec.new do |s|

  s.name         = "Localide"
  s.version      = "1.0.0"
  s.summary      = "Localide is an easy helper to offer users a personalized experience by using their favorite installed apps for directions."

  s.homepage     = "https://github.com/davoda/Localide"
  s.screenshots  = "https://raw.githubusercontent.com/davoda/Localide/master/Screenshots/Localide1.png"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "David Elsonbaty" => "dave@elsonbaty.ca" }
  s.social_media_url   = "http://twitter.com/NSDavidObject"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/davoda/Localide.git", :tag => s.version.to_s }
  s.source_files  = "Classes", "Classes/*"

  s.requires_arc = true

end
