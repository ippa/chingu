# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/lib/chingu/version'

Gem::Specification.new do |s|

  s.name = "chingu"
  s.version = Chingu::VERSION

  s.authors = ["ippa", "Ashley Engelund  (weedySeaDragon @ github) "]
  s.email = "ippa@rubylicio.us"

  s.homepage = "http://ippa.se/chingu"
  s.description = "OpenGL accelerated 2D game framework for Ruby. Builds on Gosu (Ruby/C++) which provides all the core functionality. Chingu adds simple yet powerful game states, prettier input handling, deployment safe asset-handling, a basic re-usable game object and stackable game logic."

  s.summary = "OpenGL accelerated 2D game framework for Ruby."
  
  s.files = Dir.glob("{lib,examples,benchmarks,spec}/**/*") + %w(LICENSE README.rdoc specs.watchr Rakefile LICENSE) 
  s.extra_rdoc_files = [ "LICENSE", "README.rdoc" ]  
  s.require_paths = ["lib"]  


  s.add_dependency("gosu", [">= 0.7.45"])

  s.add_development_dependency("rspec")

end

