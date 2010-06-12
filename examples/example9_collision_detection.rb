#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# Demonstrating traits "velocity" and "collision_detection"
#
class Game < Chingu::Window
  def initialize
    super(800,800)
    self.input = {:esc => :exit}
    self.caption = "Example of game object traits 'velocity' and 'effect'"
    push_game_state(ParticleState)
  end
  
  def next_effect; pop_game_state; end
end

class FireCube < Chingu::GameObject
  traits :velocity, :collision_detection  
  attr_accessor :color, :radius
  
  def initialize(options)
    super
    @mode = :additive
    
    # initialize with a rightwards velocity with some damping to look more realistic
    @velocity_x = options[:velocity_x] || 1 + rand(2)
    @velocity_y = options[:velocity_y] || 1 + rand(2)
    
    @box = Rect.new([@x, @y, 10, 10])
    @radius = 6
    
    @blue = Color.new(255,100,255,255)
    @red = Color.new(255,255,10,10)
    @color = @blue
  end
  
  def bounding_box
    @box
  end
  
  def draw
    $window.fill_rect(@box, @color)
  end
  
  def update
    @box.x, @box.y = @x, @y
    @color = @blue
  end
  
  def die!
    @color = @red
  end
  
end

class ParticleState < Chingu::GameState
  def setup    
    self.input = { :space => :new_fire_cube }
    100.times { new_fire_cube }
  end
  
  def new_fire_cube
    FireCube.create(:x => rand($window.width), :y => rand($window.height))
  end
  
  def update
    super
    
    FireCube.all.each do |particle|
      if particle.x < 0 || particle.x > $window.width
        particle.velocity_x = -particle.velocity_x
      end
      
      if particle.y < 0 || particle.y > $window.height
        particle.velocity_y = -particle.velocity_y
      end
    end
    
    #
    # GameObject.each_collsion / each_bounding_box_collision wont collide an object with itself
    #
    # FireCube.each_bounding_circle_collision(FireCube) do |cube1, cube2|  # 30 FPS on my computer
    #
    # Let's see if we can optimize each_collision, starts with 19 FPS with radius collision
    # 30 FPS by checking for radius and automatically delegate to each_bounding_circle_collision
    #
    # For bounding_box collision we start out with 7 FPS
    # Got 8 FPS, the bulk CPU consumtion is in the rect vs rect check, not in the loops.
    #
    FireCube.each_collision(FireCube) do |cube1, cube2|
      cube1.die!
      cube2.die!
    end
      
    game_objects.destroy_if { |object| object.color.alpha == 0 }
  end
  
  def draw
    $window.caption = "radius based iterative collision detection. Particles#: #{game_objects.size}, Collisionchecks each gameloop: ~#{game_objects.size**2} - FPS: #{$window.fps}"
    super
  end
end

Game.new.show
