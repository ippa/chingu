#
#
#
unless RUBY_VERSION =~ /1\.9/
  require 'rubygems'
end
require 'gosu'
require 'set'

%w{ collision_detection
    effect
    velocity
    input
    rotation_center
		}.each do |lib|
      root ||= File.dirname(File.expand_path(__FILE__))
      require File.join(root,"chingu","traits",lib)
    end

%w{	helpers
    inflector
    gfx_helpers
    core_extensions
    basic_trait_object
    basic_game_object
    trait_object
    game_object
    actor
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
  VERSION = "0.5.3.1"
end