require 'rubygems'
require '../lib/chingu.rb'
include Gosu

#
# GameState example.
#
class Game < Chingu::Window
  def initialize
    super    
    push_gamestate(Intro)
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
    @title = Chingu::Text.new(:text=>"Intro (press space)", :x=>200, :y=>50, :size=>30)
    self.keymap = { :space => Menu, :escape => :close }
  end
end

#
# GAMESTATE #2 - MENU
#
class Menu < Chingu::GameState
  def setup
    @title = Chingu::Text.new(:text => "GameState Menu (press 'm')", :x => 200, :y => 50, :size=>30)
    self.keymap = { :m => Level.new(:level => 10) }
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
    @title = Chingu::Text.new(:text=>"Level #{options[:level].to_s}. Pause with 'P'", :x=>200, :y=>10, :size => 30)
    @player = Player.new(:x => 200, :y => 200, :image => Image["spaceship.png"])
    @player.keymap = {:left => :move_left, :right => :move_right, :up => :move_up, :down => :move_down, :left_ctrl => :fire}
    self.keymap = {:p => Pause, :escape => :close}
  end    
end

#
# SPECIAL GAMESTATE - Pause
#
class Pause < Chingu::GameState
  def setup
    @title = Chingu::Text.new(:text=>"PAUSED (press 'u' to un-pause)", :x=>100, :y=>200, :size=>20, :color => Color.new(0xFF00FF00))
    self.keymap = { :u => :un_pause }
  end

  def un_pause
    pop_gamestate             # Return the previous gamestate
  end
  
  def draw
    previous_gamestate.draw   # Draw prev gamestate onto screen
    super                     # Draw game objects in current game state
  end  
end

Game.new.show