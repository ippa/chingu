require File.dirname(__FILE__) + '/lib/chingu'
require 'rspec/core/rake_task'

include Chingu

task :default => :spec

desc "Run the specs under spec"
RSpec::Core::RakeTask.new { |t| }

desc "Run the specs with rcov"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts = ['-T', '--no-html', '--exclude spec,gem']
end

desc "Build the gem"
task :build do
  Dir.mkdir('dist') unless Dir.exist?('dist')

  sh "gem build chingu.gemspec"
  puts "Moving into directory dist"
  sh "mv chingu-#{Chingu::VERSION}.gem dist/"
end
 
desc "Release new gem"
task :release => :build do
  sh "gem push dist/chingu-#{Chingu::VERSION}.gem"
end