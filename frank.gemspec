# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "frank/version"

Gem::Specification.new do |s|
  s.name        = "frank"
  s.version     = Frank::VERSION
  s.authors     = ["blahed", "nwah"]
  s.email       = ["tdunn13@gmail"]
  s.description = "Rapidly develop static sites using any supported templating language"
  s.summary = "Rapidly develop static sites using any supported templating language"

  s.rubyforge_project = "frank"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency 'rack', '~> 1.1'
  s.add_runtime_dependency 'thin'
  s.add_runtime_dependency 'haml', '~> 3.0'
  s.add_runtime_dependency 'tilt', '~> 1.3'
  
  s.add_development_dependency 'rspec', '~> 2.6.0'
  s.add_development_dependency 'rack-test', '~> 0.5'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'builder'
  s.add_development_dependency 'erubis'
  s.add_development_dependency 'compass', '~> 0.10.2'
  s.add_development_dependency 'rdiscount'
  s.add_development_dependency 'liquid'
  s.add_development_dependency 'less'
  s.add_development_dependency 'coffee-script', '~> 2.2.0'
  s.add_development_dependency 'RedCloth'
end