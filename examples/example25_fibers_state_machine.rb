#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu
Velocity = Struct.new(:x, :y, :z)

#
# Press 'E' when demo is running to edit the playfield!
# 
class Game < Chingu::Window 
  def initialize
    p RUBY_VERSION
    super(1000,600)
  end
  
  def setup
    retrofy
    switch_game_state(Example25)
  end    
end

class Example25 < GameState
  def setup
    self.input = { :escape => :exit, :e => :edit }    
    load_game_objects
    @droid = Droid.create(:x => 100, :y => 400)
  end
  
  def edit
    push_game_state(GameStates::Edit.new(:grid => [32,32], :classes => [Block]))
  end
  
  def update    
    super
    $window.caption = "x/y: #{@droid.x.to_i}/#{@droid.y.to_i} - FPS: #{$window.fps}"
  end
  
  def draw
    super
    #fill_rect(Rect.new(0,400,$window.width, 200), Color::White)
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

    @fiber = Fiber.new do |command| 
      puts "got #{command}"; loop { v = Fiber.yield(); puts "got #{v}" }
    end
    @fiber.resume :one
    @fiber.resume :two
    #exit
    
    #fiber = Fiber.new do |command|
      #while true
      #  Fiber.yield
      #end
      #velocity ||= Velocity.new
      
      #if command == :left
      #  move(-@speed, 0)
      #  @animation = @animations[:left]
      #elsif command == :right
      #  move(@speed, 0)
      #  @animation = @animations[:right]
      #end
    
      #velocity
    #end

    update
  end
  
  def holding_left
    @fiber.resume :left
  end

  def holding_right
    @fiber.resume :right
  end

  def jump
    return if @jumping
    @jumping = true
    self.velocity_y = -10
    @animation = @animations[:up]
  end
  
  def move(x,y)
    self.x += x
    self.each_collision(Block) do |me, stone_wall|
      self.x = previous_x
      break
    end
    
    self.y += y
  end
  
  def update
    @fiber.resume :jump# if holding?(:a)
    
    @image = @animation.next
    
    self.each_collision(Block) do |me, stone_wall|
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
    @color = Color.new(0xff808080)
  end
end


Game.new.show