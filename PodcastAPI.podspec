Pod::Spec.new do |s|
  s.name        = "PodcastAPI"
  s.version     = "1.1.5"
  s.summary     = "The Official Swift Library for the Listen Notes Podcast API."
  s.homepage    = "https://www.listennotes.com/podcast-api/"
  s.license     = { :type => "MIT" }
  s.author             = { "Listen Notes, Inc." => "hello@listennotes.com" }
  s.social_media_url   = "https://twitter.com/ListenNotes"

  s.requires_arc = true
  s.swift_version = "5.0"
  s.osx.deployment_target = "13.3.99"
  s.ios.deployment_target = "16.4.99"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/ListenNotes/podcast-api-swift.git", :tag => "#{s.version}" }
  s.source_files = "Sources/PodcastAPI/*.swift"
  s.dependency "SwiftyJSON", "~> 4.0"
end
