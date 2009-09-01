#
#
#
unless RUBY_VERSION =~ /1\.9/
  require 'rubygems'
end
require 'gosu'
require 'set'

%w{	helpers
    gfx_helpers
    game_object
    effects
    game_state_manager
    game_state
    window
		fpscounter
		named_resource
		assets
    text
		rect
		animation
    particle    
		input
    parallax
		}.each do |lib|
      root ||= File.dirname(File.expand_path(__FILE__))
      require File.join(root,"chingu",lib)
    end

%w{ pause
    fade_to
    debug
		}.each do |lib|
      root ||= File.dirname(File.expand_path(__FILE__))
      require File.join(root,"chingu","game_states",lib)
    end

module Chingu
  VERSION = "0.4.9"
end