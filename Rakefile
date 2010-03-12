require File.dirname(__FILE__) + "/lib/frank.rb"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "frank"
    gemspec.summary = "Stupidly Simple Static Slinger"
    gemspec.description = "Create/Dump static builds using whatever templating/helper languages you wish"
    gemspec.version = Frank::VERSION
    gemspec.email = "travis.dunn@thisismedium.com"
    gemspec.homepage = "http://github.com/blahed/frank"
    gemspec.authors = ["blahed", "nwah"]
    gemspec.add_dependency 'rack', '>=1.0'
    gemspec.add_dependency 'mongrel', '>=1.0'
    gemspec.add_dependency 'haml', '>=2.0'
    gemspec.add_development_dependency 'shoulda', '>=2.0'
    gemspec.add_development_dependency 'rack-test', '>=0.5'
    
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end