require 'rubygems'
require '../lib/chingu.rb'
include Gosu

#
# GameState example
#
class Game < Chingu::Window
  def initialize
    super
    push_gamestate(Intro.new)    
  end
end

#
# Our Player
#
class Player < Chingu::GameObject
  def move_left;  @x -= 1; end
  def move_right; @x += 1; end
  def move_up;    @y -= 1; end
  def move_down;  @y += 1; end  
end

#
# GAMESTATE #1 - INTRO
#
class Intro < Chingu::GameState 
  def setup
    @font = Gosu::Font.new($window, "verdana", 30)
    self.keymap = { :space => Menu, :escape => :close }
  end
  
  def draw
    @font.draw("Intro... (press space)", 200, 50, 10)
  end  
end

#
# GAMESTATE #2 - MENU
#
class Menu < Chingu::GameState
  def setup
    @font = Gosu::Font.new($window, "verdana", 30)
    self.keymap = { :m => Level.new(:level => 10) }
  end
  
  def draw
    @font.draw("GameState Menu (press 'm')", 200, 50, 10)
  end  
end

#
# GAMESTATE #3 - LEVEL (Gameplay, yay)
#
class Level < Chingu::GameState
  def setup
    #
    # FIX: :p => Pause.new  would Change the "inside_game_state" to Pause and make @player belong to Pause.
    #
    @font = Gosu::Font.new($window, "verdana", 30)
    @player = Player.new(:x => 200, :y => 200, :image => Image["spaceship.png"])
    @player.keymap = {:left => :move_left, :right => :move_right, :up => :move_up, :down => :move_down, :left_ctrl => :fire}
    self.keymap = {:p => Pause, :escape => :close}
  end
    
  def draw
    @font.draw("Level #{options[:level].to_s}. Pause with 'P'", 200, 10, 10)
    super
  end
end

#
# SPECIAL GAMESTATE - Pause
#
class Pause < Chingu::GameState
  def setup
    @font = Gosu::Font.new($window, "verdana", 40)
    self.keymap = { :u => :un_pause }
  end
  
  # Return the previous gamestate
  def un_pause
    pop_gamestate
  end
  
  def draw
    previous_gamestate.draw   # Draw prev gamestate onto screen
    @font.draw("PAUSED (press 'u' to continue)", 10, 200, 10)
  end  
end

Game.new.show