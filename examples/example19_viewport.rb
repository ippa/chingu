#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# viewport-trait example
#
# Gotcha: collision_detection-trait debug mode currently borks up with viewports (only the visuals)
# 
class Game < Chingu::Window 
  def setup
    self.factor = 6
    self.input = { :escape => :exit }          
    switch_game_state(Level)
  end
  
end

class Level < GameState
  #
  # This adds accessor 'viewport' to class and overrides draw() to use it.
  #
  has_trait :viewport
  
  #
  # We create our 3 different game objects in this order: 
  # 1) map 2) stars 3) player
  # Since we don't give any zorders Chingu automatically increments zorder between each object created, putting player on top
  #
  def setup
    @map = GameObject.create(:image => "background1.png", :factor => $window.factor, :rotation_center => :top_left)
    self.viewport.x_lag = 0.95	# lag goes from 0 (no lag at all) to 1 (too much lag for viewport to move ;))
    self.viewport.y_lag = 0.95
    self.viewport.x_min = 0
    self.viewport.y_min = 0
    self.viewport.x_max = @map.image.width * $window.factor - $window.width
    self.viewport.y_max = @map.image.height * $window.factor - $window.height
    
    # Create 40 stars scattered around the map
    40.times { |nr| Star.create(:x => rand * self.viewport.x_max, :y => rand * self.viewport.y_max) }
  
    @droid = Droid.create(:x => 100, :y => 100)
  end
  
  def update    
    super

    @droid.each_collision(Star) do |droid, star|
      star.destroy
      Sound["laser.wav"].play(0.5)
    end
    
    #
    # Align viewport with the droid in the middle.
    # This will make droid will be in the center of the screen all the time...
    # ...except when hitting outer borders and viewport x/y _ min/max kicks in.
    #
    self.viewport.x_target = @droid.x - $window.width / 2
    self.viewport.y_target = @droid.y - $window.height / 2
        
    $window.caption = "viewport-trait example. Move with arrows! x/y: #{@droid.x}/#{@droid.y} - viewport x/y: #{self.viewport.x}/#{self.viewport.y} - FPS: #{$window.fps}"
  end
end

class Droid < Chingu::GameObject
  has_trait :bounding_box, :debug => true
  has_traits :timer, :collision_detection 
  attr_accessor :last_x, :last_y
  
  def setup
    #
    # This shows up the shortened version of input-maps, where each key calls a method of the very same name.
    # Use this by giving an array of symbols to self.input
    #
    self.input = [:holding_left, :holding_right, :holding_up, :holding_down]
    
    # Load the full animation from tile-file media/droid.bmp
    @animations = Chingu::Animation.new(:file => "droid.bmp", :size => [11,16])
    @animations.frame_names = { :scan => 0..5, :up => 6..7, :down => 8..9, :left => 10..11, :right => 12..13 }
    
    # Start out by animation frames 0-5 (contained by @animations[:scan])
    @animation = @animations[:scan]
    
    @speed = 3
    self.factor = $window.factor
    
    @last_x, @last_y = @x, @y
    update
  end
    
  def holding_left
    @x -= @speed
    @animation = @animations[:left]
  end

  def holding_right
    @x += @speed
    @animation = @animations[:right]
  end

  def holding_up
    @y -= @speed
    @animation = @animations[:up]
  end

  def holding_down
    @y += @speed
    @animation = @animations[:down]
  end

  # We don't need to call super() in update().
  # By default GameObject#update is empty since it doesn't contain any gamelogic to speak of.
  def update
    
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation.next
    
    #
    # If droid stands still, use the scanning animation
    #
    if @x == @last_x && @y == @last_y
      @animation = @animations[:scan]
    end
    
    @x, @y = @last_x, @last_y if self.parent.outside_viewport?(self)
    @last_x, @last_y = @x, @y
  end
end

class Star < GameObject
  has_trait :bounding_circle
  has_trait :collision_detection
  
  def setup    
    @animation = Chingu::Animation.new(:file => media_path("Star.png"), :size => 25)
    @image = @animation.next
    self.color = Gosu::Color.new(0xff000000)
    self.color.red = rand(255 - 40) + 40
    self.color.green = rand(255 - 40) + 40
    self.color.blue = rand(255 - 40) + 40
    self.factor = 1
    
    #
    # A cached bounding circle will not adapt to changes in size, but it will follow objects X / Y
    # Same is true for "cache_bounding_box"
    #
    cache_bounding_circle
  end
  
  def update
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation.next
  end
end

Game.new.show