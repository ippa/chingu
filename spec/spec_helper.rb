$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

# encoding: utf-8
require 'rubygems'
require 'rspec'

require 'chingu'

if defined?(Rcov)

  # all_app_files = Dir.glob('lib/**/*.rb')
  # all_app_files.each{|rb| require rb}

end

