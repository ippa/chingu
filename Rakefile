require 'rubygems'
require 'hoe'
require File.dirname(__FILE__) + '/lib/chingu'

include Chingu

Hoe.plugin :git
Hoe.spec "chingu" do
  developer "ippa", "ippa@rubylicio.us"
  self.readme_file   = 'README.rdoc'
  self.rubyforge_name = "chingu"
  self.version = Chingu::VERSION
end

desc "Build a working gemspec"
task :gemspec do
  system "rake git:manifest"
  system "rake debug_gem | grep -v \"(in \" | grep -v \"erik\" > chingu.gemspec"
end


#begin
#  require 'jeweler'
#  Jeweler::Tasks.new do |gemspec|
#    gemspec.name = "chingu"
#    gemspec.summary = "Game framework built on top of the OpenGL accelerated game lib Gosu"
#    gemspec.description = "Game framework built on top of the OpenGL accelerated game lib Gosu"
#    gemspec.email = "ippa@rubylicio.us"
#    gemspec.homepage = "http://github.com/ippa/chingu"
#    gemspec.authors = ["ippa"]
#    gemspec.rubyforge_project = "chingu"
#  end
#rescue LoadError
#  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
#end
