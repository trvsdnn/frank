begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "frank"
    gemspec.summary = "Stupidly Simple Static Slinger"
    gemspec.description = "Create/Dump static builds using whatever templating/helper languages you wish"
    gemspec.email = "travis.dunn@thisismedium.com"
    gemspec.homepage = "http://github.com/blahed/frank"
    gemspec.authors = ["blahed", "nwah"]
    gemspec.add_dependency 'rack'
    gemspec.add_dependency 'mongrel'
    gemspec.add_dependency 'haml'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end