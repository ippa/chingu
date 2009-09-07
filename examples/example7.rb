require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# GFXHelpers example - demonstrating Chingus GFX
#
class Game < Chingu::Window
  def initialize
    super(640,400)
    self.input = {:space => :next_effect, :esc => :exit}
    self.caption = "Example of Chingus GFX Helpers"
    
    push_game_state(Fill)
    push_game_state(FillRect)
    push_game_state(FillGradient)
    push_game_state(FillGradientRect)
    push_game_state(Particles)
  end
  
  def next_effect
    pop_game_state
  end
end


class Fill < Chingu::GameState 
  def setup
    @white = Color.new(255,255,255,255)
  end
  def draw
    $window.caption = "fill (space to continue)"
    fill(@white)
  end
end

class FillRect < Chingu::GameState 
  def setup
    @white = Color.new(255,255,255,255)
  end
  def draw
    $window.caption = "fill_rect (space to continue)"
    fill_rect([10,10,100,100], @white)
  end
end

class FillGradient < Chingu::GameState 
  def setup
    @pinkish = Color.new(0xFFCE17B6)
    @blueish = Color.new(0xFF6DA9FF)
  end
  
  def draw
    $window.caption = "fill_gradient (space to continue)"
    fill_gradient(:from => @pinkish, :to => @blueish, :orientation => :vertical)
  end
end

class FillGradientRect < Chingu::GameState 
  def setup
    @color1 = Color.new(0xFFFFEA02)
    @color2 = Color.new(0xFF078B20)
  end
  
  def draw
    $window.caption = "fill_gradient with :rect-option (space to continue)"
    fill_gradient(:from => @color1, :to => @color2, :rect => [100,100,200,200], :orientation => :horizontal)
  end
end

class Particles < Chingu::GameState
  def setup
    @color1 = Color.new(0xFFFFEA02)
    @color2 = Color.new(0xFF078B20)
    @blue_laserish = Color.new(0xFF86EFFF)
    @red = Color.new(0xFFFF0000)
    @white = Color.new(0xFFFFFFFF)
    @yellow = Color.new(0xFFF9F120)
    
    # Thanks jsb in #gosu of Encave-fame for fireball.png :)
    @fireball_animation = Chingu::Animation.new(:file => media_path("fireball.png"), :width => 32, :height => 32)
    @ground_y = $window.height * 0.95
  end
  
  def update
    #
    # Fire 1. Dies quickly (big :fade). Small in size (small :zoom)
    #
    Chingu::Particle.new( :x => 100, 
                          :y => @ground_y, 
                          :animation => @fireball_animation,
                          :zooming => +0.05, 
                          :fading => -10, 
                          :rotating => +1,
                          :mode => :default
                        )

    #
    # Fire 2. Higher flame, :fade only -4. Wide Flame with bigger :zoom.
    #
    Chingu::Particle.new( :x => 300, 
                          :y => @ground_y, 
                          :animation => @fireball_animation, 
                          :zooming => +0.2, 
                          :fading => -4, 
                          :rotating => +3,
                          :mode => :default
                        )
    #
    # Fire 3. Blue plasma with smooth particle.png and color-overlay.
    #
    Chingu::Particle.new( :x => 500, 
                          :y => @ground_y,
                          :image => "particle.png", 
                          :color => @blue_laserish,
                          :mode => :additive
                        )

    game_objects_of_class(Particle).each { |particle| particle.y -= 5; particle.x += 2 - rand(4) }
    self.game_objects.reject! { |object| object.outside_window? || object.color.alpha == 0 }
    super
  end
  
  def draw
    $window.caption = "particle example (space to continue) [particles#: #{game_objects.size} - framerate: #{$window.fps}]"
    fill_gradient(:from => Color.new(255,0,0,0), :to => Color.new(255,60,60,80), :rect => [0,0,$window.width,@ground_y])
    fill_gradient(:from => Color.new(255,100,100,100), :to => Color.new(255,50,50,50), :rect => [0,@ground_y,$window.width,$window.height-@ground_y])
    super
  end
end

Game.new.show
