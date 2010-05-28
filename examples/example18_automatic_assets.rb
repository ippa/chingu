#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# automatic_asset-trait example
# 
class Game < Chingu::Window	
  def initialize
    super(400, 400)
    self.input = { :escape => :exit }
		switch_game_state(Play)
  end
end

class Play < Chingu::GameState
	has_trait :timer
	
	def setup
		every(1000) { Spaceship.create(:x => 10, :y => 300, :velocity_x => 1) }
		every(1000) { Plane.create(:x => 10, :y => 10, :velocity_x => 1, :velocity_y => 1) }
		every(500) { FireBullet.create(:x => 10, :y => 200, :velocity_x => 1) }
		Droid.create(:x => 200, :y => 200, :factor => 10, :alpha => 100)
	end

	def update
		super
		$window.caption = "game_objects: #{game_objects.size}"
	end
end
	
class Actor < GameObject
	has_trait :automatic_assets, :delay => 100, :debug => true
	has_trait :velocity	
end

class Spaceship < Actor; end 	# spaceship.png will be loaded
class Plane < Actor; end			# plane.png will be loaded
class FireBullet < Actor; end # fire_bullet.png will be loaded
class Droid < Actor; end			# droid-11x16.png will be loaded and animated with :delay parameter, each frame beeing 11 x 16 pixels

Game.new.show