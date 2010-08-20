#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu

#
# animation-trait example
# 
class Game < Chingu::Window	
  def initialize
    super(400, 400)
    self.input = { :escape => :exit }
    switch_game_state(Play)
  end
end

class Play < Chingu::GameState
  trait :timer
	
  def setup
    Droid.create(:x => 200, :y => 300, :factor => 4, :alpha => 100)
    every(1000) { Spaceship.create(:x => 10, :y => 300, :velocity_x => 1) }
    every(1000) { Plane.create(:x => 10, :y => 350 + rand(20), :velocity => [1,0]) }
    every(500) { FireBullet.create(:x => 10, :y => 370, :velocity_x => 1) }
    every(500) { Star.create(:x => 400, :y => 400, :velocity => [-2,-rand*2]) }
    #every(400) { Heli.create(:x => 10, :y => 10, :velocity_x => 1) }
  end

  def update
    super
    game_objects.select { |game_object| game_object.outside_window? }.each(&:destroy)
    $window.caption = "game_objects: #{game_objects.size}"
  end
end
	
class Actor < GameObject
  trait :velocity
  
  def setup
    @image = Image["#{self.filename}.png"] rescue nil
    @zorder = 10
  end
  
end

class Spaceship < Actor; end  # spaceship.png will be loaded
class Plane < Actor; end      # plane.png will be loaded
class FireBullet < Actor; end # fire_bullet.png will be loaded

#
# droid_11x16.png will be loaded and animated with :delay parameter, each frame beeing 11 x 16 pixels
#
class Droid < Actor
  trait :animation, :delay => 200
  
  def update
    @image = self.animation.next  if self.animation
  end
end

#
# heli.png will be loaded
# since it doesn't contain any framesize information, chingu will assume same width and height
#
class Heli < Actor
  trait :animation, :delay => 200
  
  def update
    @image = self.animation.next  if self.animation
    p self.animation
  end
end

#
# star_25x25_default.png and star_25x25_explode.png will be loaded.
# Access the 2 animation-"states" with self.animations[:default] and self.animations[:explode]
# self.animation will point to self.animations[:default]
#
class Star < Actor
  trait :animation, :delay => 100
  
  def setup
    self.animations[:explode].loop = false
  end
  
  def update
    
    if @x < $window.width/2 || @y < $window.height/2
      @image = self.animations[:explode].next
    else
      @image = self.animations[:default].next
    end
  end
  
end

Game.new.show