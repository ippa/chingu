require 'rubygems'
require File.dirname(__FILE__) + '/lib/chingu'
include Chingu

gem 'rspec', '>= 2.1.0'
require 'rspec/core/rake_task'

desc 'Run the specs under spec'
RSpec::Core::RakeTask.new { |t| }

# desc 'Run the specs with rcov'
# RSpec::Core::RakeTask.new(:rcov) do |t|
#   t.rcov = true
#   t.rcov_opts = ['-T', '--no-html', '--exclude spec,gem']
# end
# task :default => :spec

desc 'Build gem'
task :build do
  system 'gem build chingu.gemspec'
  puts 'Moving into directory pkg'
  system "mv chingu-#{Chingu::VERSION}.gem pkg/"
end
 
desc 'Release new gem'
task :release => :build do
  system "gem push pkg/chingu-#{Chingu::VERSION}.gem"
end