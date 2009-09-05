require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# Demonstrating domponents "velocity" and "effect"
#
class Game < Chingu::Window
  def initialize
    super(640,400)
    self.input = {:esc => :exit}
    self.caption = "Example of game object components 'velocity' and 'effect'"
    push_game_state(Particles)
  end
  
  def next_effect; pop_game_state; end
end

class Plasma < Chingu::GameObject
  add_component :velocity, :effect

  def initialize(options)
    super    
    @image = Image["particle.png"]
    @mode = :additive
    
    # initialize with a rightwards velocity with some damping to look more realistic
    @velocity_x = 10
    @acceleration_x = -0.1
    
    # Simulate gravity
    @acceleration_y = 0.4
  end
end

class Particles < Chingu::GameState
  def setup
    @color1 = Color.new(0xFFFFEA02)
    @color2 = Color.new(0xFF078B20)    
    @ground_y = $window.height * 0.95
  end
  
  def update
    Plasma.new(:x => rand(2), :y => 50 + rand(5), :color => Color.new(0xFF86EFFF))
    
    Plasma.all.each do |particle| 
      particle.x += 1 - rand(2)
      
      #
      # If particle hits the ground:
      #
      if particle.y >= @ground_y
        
        # 1) "Bounce" it up particle by reversing velocity_y with damping
        particle.velocity_y = -(particle.velocity_y/3) - rand(particle.velocity_y/3)
        
        # 2) "Bounce" it randomly to left and right
        if rand(2) == 0
          particle.velocity_x = particle.velocity_y/2 + rand(2)
          particle.acceleration_x = -0.02
        else
          particle.velocity_x = -(particle.velocity_y/2) - rand(2)
          particle.acceleration_x = 0.02
        end
        
        # 3) Start fading the alphachannel
        particle.fading = -3
      end
    end
    
    self.game_objects.reject! { |object| object.outside_window? || object.color.alpha == 0 }
    super
  end
  
  def draw
    $window.caption = "particle example (esc to quit) [particles#: #{game_objects.size} - framerate: #{$window.fps}]"
    fill_gradient(:from => Color.new(255,0,0,0), :to => Color.new(255,60,60,80), :rect => [0,0,$window.width,@ground_y])
    fill_gradient(:from => Color.new(255,100,100,100), :to => Color.new(255,50,50,50), :rect => [0,@ground_y,$window.width,$window.height-@ground_y])
    super
  end
end

Game.new.show
