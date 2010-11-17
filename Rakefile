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
    
    gemspec.add_dependency 'gosu', '>= 0.7.24'
    gemspec.add_development_dependency 'rspec', '>= 2.0.0'
    gemspec.add_development_dependency 'watchr'
    gemspec.add_development_dependency 'rcov'
    gemspec.add_development_dependency 'rest_client'
    gemspec.add_development_dependency 'crack'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

# Rake RSpec2 task stuff
gem 'rspec', '>= 2.0.0'

require 'rspec/core/rake_task'

desc "Run the specs under spec"
RSpec::Core::RakeTask.new do |t|
end

desc "Run the specs with rcov (for some reason always reports wrong code coverage)"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts = ['-T', '--no-html', '--exclude spec,gem']
end

task :default => :spec
