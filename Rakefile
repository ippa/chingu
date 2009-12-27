require 'rubygems'
require File.dirname(__FILE__) + '/lib/chingu'
include Chingu

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "chingu"
    gemspec.summary = "OpenGL accelerated 2D game framework for Ruby"
    gemspec.description = "OpenGL accelerated 2D game framework for Ruby. Builds on Gosu (Ruby/C++) which provides all the core functionality. Chingu adds simple yet powerful game states, prettier input handling, deployment safe asset-handling, a basic re-usable game object and stackable game logic."
    gemspec.email = "ippa@rubylicio.us"
    gemspec.homepage = "http://github.com/ippa/chingu"
    gemspec.authors = ["ippa"]
    gemspec.rubyforge_project = "chingu"
    gemspec.version = Chingu::VERSION
    gemspec.add_dependency 'gosu'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
