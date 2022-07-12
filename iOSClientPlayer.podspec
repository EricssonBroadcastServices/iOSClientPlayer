Pod::Spec.new do |spec|
spec.name         = "iOSClientPlayer"
spec.version      = "3.0.500"
spec.summary      = "RedBeeMedia iOS SDK Player Module"
spec.homepage     = "https://github.com/EricssonBroadcastServices"
spec.license      = { :type => "Apache", :file => "https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/LICENSE" }
spec.author             = { "EMP" => "jenkinsredbee@gmail.com" }
spec.documentation_url = "https://github.com/EricssonBroadcastServices/iOSClientPlayer/tree/master/Documentation"
spec.platforms = { :ios => "9.0", :tvos => "9.0" }
spec.source       = { :git => "https://github.com/EricssonBroadcastServices/iOSClientPlayer.git", :tag => "v#{spec.version}" }
spec.source_files  = "Sources/iOSClientPlayer/**/*.swift"
end
