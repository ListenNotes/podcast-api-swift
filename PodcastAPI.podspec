Pod::Spec.new do |s|
  s.name        = "PodcastAPI"
  s.version     = "3.1.0"
  s.summary     = "The Official Swift Library for the Listen Notes Podcast API."
  s.homepage    = "https://www.listennotes.com/api/"
  s.license     = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Listen Notes, Inc." => "hello@listennotes.com" }
  s.social_media_url   = "https://twitter.com/ListenNotes"

  s.requires_arc = true
  s.swift_version = "6.0"
  s.module_name = "PodcastAPI"
  s.osx.deployment_target = "13.0"
  s.ios.deployment_target = "16.0"
  s.source       = { :git => "https://github.com/ListenNotes/podcast-api-swift.git", :tag => "#{s.version}" }
  s.source_files = "Sources/PodcastAPI/**/*.swift"
end
