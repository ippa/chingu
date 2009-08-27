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
