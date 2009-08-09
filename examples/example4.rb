require 'rubygems'
require '../lib/chingu.rb'
include Gosu

#
# Example demonstrating jumping between 4 different game states.
#
# push_gamestate, pop_gamestate and previous_gamestate are 3 helpers that Chingu mixes in
# into Chingu::Window and Chingu::GameState
#
# Behind the scenes they work against @game_state_manager that's autocreated within Chingu::Window.
#
# Execution in example4 flows like this:
#
# 1) Core Gosu calls instancemethods draw / update in the class based on Gosu::Window
#    In this example 'Game' since "Game < Chingu::Window" and "Chingu::Window < Gosu::Window"
# 
# 2) In its turn Game (Chingu::Window) calls @game_state_manager.draw / update
#
# 3) @game_state_manager calls draw / update on the current active game state
#
# 4) Each gamestate keeps a collection @game_objects which it calls draw / update on.
#    Any object based on Chingu::GameObject (In this example Player and Text) automatically
#    gets added to the correct state or or main window.
#

#
# Our standard Chingu::Window that makes all the magic happen.
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
  def initialize(options)
    super
    @image = Image["spaceship.png"]
  end
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
    @title = Chingu::Text.new(:text=>"Level #{options[:level].to_s}. Pause with 'P'", :x=>200, :y=>10, :size => 30)
    @player = Player.new(:x => 200, :y => 200)    
    @player.keymap = {:left => :move_left, :right => :move_right, :up => :move_up, :down => :move_down, :left_ctrl => :fire}
    
    #
    # The keymapper understands gamestates, when 'p' is pressed push_gamegate(Pause) will be called.
    #
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
    super                     # Draw game objects in current game state, this includes Chingu::Texts
  end  
end

Game.new.show