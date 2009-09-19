require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# Demonstrating domponents "velocity" and "effect"
#
class Game < Chingu::Window
  def initialize
    super(800,800)
    self.input = {:esc => :exit}
    self.caption = "Example of game object traits 'velocity' and 'effect'"
    push_game_state(Particles)
  end
  
  def next_effect; pop_game_state; end
end

class FireCube < Chingu::GameObject
  has_traits :velocity, :effect
  has_trait :collision_detection
  #
  # TODO:
  # has_trait :collision_detection, :type => :bounding_box
  # has_trait :collision_detection, :type => :radius
  #
  
  attr_accessor :color, :radius
  
  def initialize(options)
    super    
    @mode = :additive
    
    # initialize with a rightwards velocity with some damping to look more realistic
    @velocity_x = options[:velocity_x] || 1 + rand(3)
    @velocity_y = options[:velocity_y] || 1 + rand(3)
    
    @bounding_box = Rect.new([@x, @y, 5, 5])
    @radius = 20
    
    @color = Color.new(255,100,255,255)
  end
  
  def draw
    $window.fill_rect(@bounding_box, @color)
  end
  
  def die!
    @color = Color.new(255,255,255,255)
    self.fading = -20
    self.detect_collisions = false
  end
  
end

class Particles < Chingu::GameState
  def setup    
    self.input = { :space => :new_fire_cube }
    100.times { new_fire_cube }
  end
  
  def new_fire_cube
    FireCube.new(:x => rand($window.width), :y => rand($window.height))
  end
  
  def update        
    FireCube.all.each do |particle|
      if particle.x < 0 || particle.x > $window.width
        particle.velocity_x = -particle.velocity_x
      end
      
      if particle.y < 0 || particle.y > $window.height
        particle.velocity_y = -particle.velocity_y
      end
    end
    
    #
    # GameObject.each_collsion wont collide an object with itself
    #
    FireCube.each_collision(FireCube) do |cube1, cube2|
      #cube1.die!
      #cube2.die!
    end
      
    game_objects.destroy_if { |object| object.color.alpha == 0 }
    
    super
  end
  
  def draw
    $window.caption = "particle example (esc to quit) [particles#: #{game_objects.size} - framerate: #{$window.fps}]"
    super
  end
end

Game.new.show
