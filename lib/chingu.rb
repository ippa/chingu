#
#
#
#
require 'rubygems'
require 'gosu'
require 'set'

%w{	helpers
    gfx_helpers
    game_state_manager
    game_state
    window
		fpscounter
		named_resource
		assets
    game_object
    text
		rect
		animation
		input
    parallax
		}.each do |lib|
      root ||= File.dirname(File.expand_path(__FILE__))
      require File.join(root,"chingu",lib)
    end

%w{ pause
    fade_to
		}.each do |lib|
      root ||= File.dirname(File.expand_path(__FILE__))
      require File.join(root,"chingu","game_states",lib)
    end

module Chingu
  VERSION = "0.4.4"
end