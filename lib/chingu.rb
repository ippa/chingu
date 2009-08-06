#
#
#
#
require 'rubygems'
require 'gosu'

%w{	window
		fpscounter
		named_resource
		assets
    actor
		advanced_actor
		data_structures
		rect
		animation
		keymap
    paralaxx
		}.each do |lib|
      root ||= File.dirname(File.expand_path(__FILE__))
      require File.join(root,"chingu",lib)
    end

module Chingu
  VERSION = "0.0.1"
end