#
#
#
CHINGU_ROOT = File.dirname(File.expand_path(__FILE__))

require 'rubygems' unless RUBY_VERSION =~ /1\.9/
require 'gosu'
require 'set'
require File.join(CHINGU_ROOT,"chingu","require_all") # Thanks to http://github.com/tarcieri/require_all !
require_all "#{CHINGU_ROOT}/chingu"

module Chingu
  VERSION = "0.5.3.1"
end