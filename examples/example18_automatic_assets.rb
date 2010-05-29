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
    Droid.create(:x => 200, :y => 200, :factor => 10, :alpha => 100)
    every(1000) { Spaceship.create(:x => 10, :y => 300, :velocity_x => 1) }
    every(1000) { Plane.create(:x => 10, :y => 10, :velocity => [1,1] ) }
    every(500) { FireBullet.create(:x => 10, :y => 200, :velocity_x => 1) }
    every(500) { Star.create(:x => 400, :y => 400, :velocity => [-2,-rand*2]) }
  end

  def update
    super
    $window.caption = "game_objects: #{game_objects.size}"
  end
end
	
class Actor < GameObject
  has_trait :automatic_assets, :delay => 100
  has_trait :velocity
  
  def update
    destroy if outside_window?
    @image = @animation.next if @animation
  end
end

class Spaceship < Actor; end  # spaceship.png will be loaded
class Plane < Actor; end      # plane.png will be loaded
class FireBullet < Actor; end # fire_bullet.png will be loaded
class Droid < Actor; end      # droid_11x16.png will be loaded and animated with :delay parameter, each frame beeing 11 x 16 pixels

#
# star_25x25_default.png and star_25x25_explode.png will be loaded.
# Access the 2 animation-"states" with animation[:default] and animation[:explode]
# You could also change the default playing animation with switch_animation(state)
#
class Star < Actor
  def update
    if @x < $window.width/2 || @y < $window.height/2
      @animation = self.animations[:explode]
      @animation.loop = false
    end
    super
  end
end

Game.new.show