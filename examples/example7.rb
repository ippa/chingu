require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu

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
    @pinkish = Color.new(0xFFF289FF)
    @blueish = Color.new(0xFF6DA9FF)
  end
  
  def draw
    $window.caption = "fill_gradient (space to continue)"
    fill_gradient(:from => @pinkish, :to => @blueish, :orientation => :vertical)
  end
end

Game.new.show
