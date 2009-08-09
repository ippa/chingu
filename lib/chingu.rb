#
#
#
#
require 'rubygems'
require 'gosu'

%w{	helpers
    game_state_manager
    game_state
    window
		fpscounter
		named_resource
		assets
    game_object
    text
		data_structures
		rect
		animation
		keymap
    parallax
		}.each do |lib|
      root ||= File.dirname(File.expand_path(__FILE__))
      require File.join(root,"chingu",lib)
    end

module Chingu
  VERSION = "0.0.2"
end