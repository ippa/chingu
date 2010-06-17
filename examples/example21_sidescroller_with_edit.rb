#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# Press 'E' when demo is running to edit the playfield!
# 
class Game < Chingu::Window 
  def initialize
    super(1000,700)
  end
  
  def setup
    Gosu::enable_undocumented_retrofication
    switch_game_state(Example21.new)
  end    
end

#
# The Game
#
class Example21 < GameState
  traits :viewport, :timer
  
  def setup
    self.input = { :escape => :exit, :e => :edit }
    self.viewport.game_area = [0, 0, 3000, 1000]    
    
    @droid = Droid.create(:x => 100, :y => 300)
    #@droid = Droid.create(:x => 2500, :y => 1200)
    #@droid = Droid.create(:x => 500, :y => 1500)
    
    load_game_objects
    
    # Reverse the cog wheels in relation to eachother
    CogWheel.each_collision(CogWheel) do |cog_wheel, cog_wheel_2|
      cog_wheel_2.angle_velocity = -cog_wheel.angle_velocity
    end
    
    @saved_x, @saved_y = [100, 300]
    every(5000) { save_player_position }
  end
  
  def edit
    push_game_state(GameStates::Edit.new(:grid => [32,32], :classes => [Tube, CogWheel, Block, Saw, Battery]))
  end
  
  def restore_player_position
    @droid.x, @droid.y = @saved_x, @saved_y
  end
  
  def save_player_position
    @saved_x, @saved_y = @droid.x, @droid.y   if @droid.collidable && !@jumping
  end

  def update    
    super
    
    visible_blocks = Block.inside_viewport
    
    FireBall.each_collision(visible_blocks) do |fire_ball, block|
      fire_ball.destroy
    end
    
    # Makes all saw pendle up and down between Y-coordinate 1000 - 1500
    # TODO: Not a very flexible sollution, how about setting out circle,rects,lines in editor..
    # .. when then can be used for this kind of stuff?
    Saw.all.select {|saw| saw.y < 1300 || saw.y > 1550 }.each do |saw|
      saw.velocity_y = -saw.velocity_y
      saw.y += saw.velocity_y * saw.factor_y 
    end

    @droid.each_collision(FireBall, Saw) do |player, evil_object|
      player.die
    end
      
    @droid.each_collision(Battery) do |player, battery|
      battery.die
      #after(3000) { push_game_state(GameFinished) }
    end
  
        
    self.viewport.center_around(@droid)
        
    $window.caption = "Haunted Factory. 'E' toggles Edit. x/y: #{@droid.x.to_i}/#{@droid.y.to_i} - viewport x/y: #{self.viewport.x.to_i}/#{self.viewport.y.to_i} - FPS: #{$window.fps}"
  end
end

  
#
# DROID
#
class Droid < Chingu::GameObject
  trait :bounding_box, :scale => 0.80
  traits :timer, :collision_detection , :timer, :velocity
  
  attr_reader :jumpign
  
  def setup
    self.input = {  [:holding_left, :holding_a] => :holding_left, 
                    [:holding_right, :holding_d] => :holding_right,
                    [:up, :w] => :jump,
                  }
    
    # Load the full animation from tile-file media/droid.bmp
    @animations = Chingu::Animation.new(:file => "droid_11x15.bmp")
    @animations.frame_names = { :scan => 0..5, :up => 6..7, :down => 8..9, :left => 10..11, :right => 12..13 }
    
    @animation = @animations[:scan]
    @speed = 3
    @jumping = false
    
    self.zorder = 300
    self.factor = 3
    self.acceleration_y = 0.5
    self.max_velocity = 10
    self.rotation_center = :bottom_center

    update
  end
  
  def die
    self.collidable = false
    @color = Color::RED
    between(1,600) { self.velocity_y = 0; self.scale += 0.2; self.alpha -= 5; }.then { resurrect }
  end
    
  def resurrect
    self.alpha = 255
    self.factor = 3
    self.collidable = true
    @color = Color::WHITE
    game_state.restore_player_position
  end

  def holding_left
    move(-@speed, 0)
    @animation = @animations[:left]
  end

  def holding_right
    move(@speed, 0)
    @animation = @animations[:right]
  end

  def jump
    return if @jumping
    @jumping = true
    self.velocity_y = -10
    @animation = @animations[:up]
  end
  
  def move(x,y)
    @x += x
    self.each_collision(Block.inside_viewport) do |me, stone_wall|
      me.x = previous_x
    end
  end
  
  def update    
    @image = @animation.next
    self.each_collision(Block.inside_viewport) do |me, stone_wall|
      if self.velocity_y < 0  # Hitting the ceiling
        me.y = stone_wall.bb.bottom + me.image.height * self.factor_y
        self.velocity_y = 0
      else  # Land on ground
        @jumping = false        
        me.y = stone_wall.bb.top-1
      end
    end
    
    @animation = @animations[:scan] unless moved?
  end
end

#
# TUBE
#
class Tube < GameObject
  traits :bounding_box, :timer
  def setup
    @image = Image["tube.png"]
    every(3000)  { fire }
    cache_bounding_box
  end
  
  def fire
    return if game_state.viewport.outside?(self.bb.centerx, self.bb.bottom)
    FireBall.create(:x => self.bb.centerx - rand(10), :y => self.bb.bottom - rand(10))
  end
end

#
# BATTERY
#
class Battery < GameObject
  traits :timer, :effect
  trait :bounding_box, :debug => false
  
  def setup
    @image = Image["battery.png"]
    cache_bounding_box
  end
  
  def die   
    self.collidable = false # Stops further collisions in each_collsiion() etc.
    self.rotation_rate = 5
    self.scale_rate = 0.005
    self.fade_rate = -5
    after(2000) { destroy }
  end  
end

#
# A FIREBALL
#
class FireBall < GameObject
  traits :velocity, :collision_detection
  trait :bounding_circle, :scale => 0.7
  
  def setup
    @animation = Animation.new(:file => "fireball.png", :size => [32,32], :delay => 20)
    @image = @animation.first
    self.mode = :additive
    self.factor = 3
    self.velocity_y = 1
    self.zorder = 200
    self.rotation_center = :center
  end
  
  def update
    @image = @animation.next
    @angle += 2
  end
end

#
# COG WHEEL
#
class CogWheel < GameObject
  traits :bounding_circle, :collision_detection, :timer
  attr_accessor :angle_velocity
  
  def setup    
    @image = Image["cog_wheel.png"]
    @angle_velocity = 1 / self.factor_x
  end
  
  def update
    self.angle += @angle_velocity
  end
end

#
# SAW
#
class Saw < GameObject
  traits :bounding_circle, :collision_detection, :timer, :velocity
  attr_accessor :angle_velocity
  
  def setup    
    @image = Image["saw.png"]
    @angle_velocity = 3.0 / self.factor_x.to_f
    self.velocity_y = 1.0 / self.factor_x.to_f
  end
  
  def update
    self.angle += @angle_velocity
  end
end

#
# BLOCK, our basic level building block
#
class Block < GameObject
  trait :bounding_box, :debug => false
  trait :collision_detection
  
  def self.solid
    all.select { |block| block.alpha == 255 }
  end

  def self.inside_viewport
    all.select { |block| block.game_state.viewport.inside?(block) }
  end

  def setup
    @image = Image["black_block.png"]
  end
end

Game.new.show