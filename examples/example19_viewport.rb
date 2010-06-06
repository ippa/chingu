#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# viewport-trait / edit-trait example
#
# Press 'E' when demo is running to edit the playfield!
# 
class Game < Chingu::Window 
  def setup
    Gosu::enable_undocumented_retrofication
    self.factor = 3
    self.input = { :escape => :exit }
    switch_game_state(Level.new)
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
    self.input = { :e => :edit } 

    Sound["laser.wav"] # cache sound by accessing it once
    
    @map = GameObject.create(:image => "background1.png", :factor => $window.factor, :rotation_center => :top_left)
    self.viewport.x_lag = 0.95	# lag goes from 0 (no lag at all) to 1 (too much lag for viewport to move ;))
    self.viewport.y_lag = 0.95
    self.viewport.x_min = 0
    self.viewport.y_min = 0
    self.viewport.x_max = @map.image.width * $window.factor - $window.width
    self.viewport.y_max = @map.image.height * $window.factor - $window.height
    
    #
    # Create 40 stars scattered around the map
    # This is not replaced by load_game_objects()
    #
    # 40.times { |nr| Star.create(:x => rand * self.viewport.x_max, :y => rand * self.viewport.y_max) }
    
    load_game_objects(:file => "example19_game_objects.yml" )
  
    # Create our mechanic star-hunter
    @droid = Droid.create(:x => 100, :y => 100)    
  end

  def edit
    push_game_state(GameStates::Edit.new(:file => "example19_game_objects.yml", :classes => [Star, StoneWall]))
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
    # ...except when hitting outer borders and viewport x_min/max & y_min/max kicks in.
    #
    self.viewport.x_target = @droid.x - $window.width / 2
    self.viewport.y_target = @droid.y - $window.height / 2
        
    $window.caption = "viewport/edit-trait example. Move with arrows! Press 'E' to Edit. x/y: #{@droid.x.to_i}/#{@droid.y.to_i} - viewport x/y: #{self.viewport.x.to_i}/#{self.viewport.y.to_i} - FPS: #{$window.fps}"
  end
end

class Droid < Chingu::GameObject
  has_trait :bounding_box, :debug => false
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
    @speed = 2
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
    
    #
    # Revert player to last positions when:
    # - player is outside the viewport
    # - player is colliding with at least one object of class StoneWall
    #
    if self.parent.outside_viewport?(self) || self.first_collision(StoneWall)
      @x, @y = @last_x, @last_y
    end
    
    @last_x, @last_y = @x, @y
  end
end

class Star < GameObject
  has_trait :bounding_circle, :debug => false
  has_trait :collision_detection
  
  def setup    
    @animation = Chingu::Animation.new(:file => "Star.png", :size => 25)
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

class StoneWall < GameObject
  has_traits :bounding_box, :collision_detection
  
  def setup
    @image = Image["stone_wall.bmp"]
    self.factor = 1
  end
end

Game.new.show