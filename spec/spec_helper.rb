# encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'require_all'

require 'chingu'

def media_path(file)
  File.join($window.root, "..", "..", "examples", "media", file)
end

if defined?(Rcov)
  # all_app_files = Dir.glob('lib/**/*.rb')
  # all_app_files.each{|rb| require rb}
end

