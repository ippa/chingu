#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu

#
# Example demonstrating jumping between 4 different game states.
#
# push_game_state, pop_game_state, current_game_state previous_game_state are 4 helper-methods that Chingu mixes in
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
# 4) Each game state keeps a collection @game_objects which it calls draw / update on.
#    Any object based on Chingu::GameObject (In this example Player and Text) automatically
#    gets added to the correct state or or main window.
#

#
# Our standard Chingu::Window that makes all the magic happen.
#
class Game < Chingu::Window
  def initialize
    super
    
    push_game_state(Intro)
    
    # Yes you can do crazy things like this :)
    self.input = { :left_mouse_button => lambda{Chingu::Text.create(:text => "Woof!")}, :esc => :exit}
  end
end

# Our Player 
class Player < Chingu::GameObject
  def initialize(options = {})
    super
    @image = Image["spaceship.png"]
  end
  
  def move_left;  @x -= 1; end
  def move_right; @x += 1; end
  def move_up;    @y -= 1; end
  def move_down;  @y += 1; end 

  def fire
    #puts "current_scope: #{$window.current_scope.to_s}"
    #puts "inside_state: #{$window.game_state_manager.inside_state}"
    Bullet.create(:x => @x - 20, :y => @y)
    Bullet.create(:x => @x, :y => @y) 
    Bullet.create(:x => @x + 20, :y => @y)
  end  
end

# The bullet the Player fires
class Bullet < Chingu::GameObject
  def initialize(options)
    super
    @image = Image["fire_bullet.png"]
  end
  
  def update
    @y -= 2
  end
end


#
# GAMESTATE #1 - INTRO
#
class Intro < Chingu::GameState 
  def initialize(options = {})
    super
    @title = Chingu::Text.create(:text=>"Press and release F1", :x=>200, :y=>50, :size=>30)
    self.input = { :f1 => :pressed, :released_f1 => :released, :f2 => Menu}
  end
  
  def pressed
    @title.text = "F1 pressed (F2 to continue)"
  end
  
  def released
    @title.text = "F1 released (F2 to continue)"
  end
end

#
# GAMESTATE #2 - MENU
#
class Menu < Chingu::GameState
  def initialize(options = {})
    super
    @title = Chingu::Text.create(:text => "Press 'S' to Start game", :x=>100, :y=>50, :size=>30)
    self.input = { :s => Level.new(:level => 10) }
  end
end

#
# GAMESTATE #3 - LEVEL (Gameplay, yay)
#
class Level < Chingu::GameState
  #
  # initialize() is called when you create the game state
  #
  def initialize(options = {})
    super
    @title = Chingu::Text.create(:text=>"Level #{options[:level].to_s}. P: pause R:restart", :x=>20, :y=>10, :size=>30)
    @player = Player.create
    
    #
    # The below code can mostly be replaced with the use of methods "holding?", "holding_all?" or "holding_any?" in Level#update
    # Using holding? in update could be good if you need fine grained controll over when input is dispatched.
    # 
    @player.input = {  :holding_left => :move_left, 
                       :holding_right => :move_right, 
                       :holding_up => :move_up, 
                       :holding_down => :move_down, 
                       :space => :fire }

    #
    # The input-handler understands gamestates. P is pressed --> push_gamegate(Pause)
    # You can also give it Procs/Lambdas which it will execute when key is pressed.
    #
    self.input = {:p => Pause, :r => lambda{ current_game_state.setup } }
  end
  
  def update
    super
    
    #
    # Another way of checking input
    #
    # @player.move_left   if holding_any?(:left, :a)
    # @player.move_right  if holding_any?(:right, :d)
    # @player.move_up     if holding_any?(:up, :w)
    # @player.move_down   if holding_any?(:down, :s)
    # @player.fire        if holding?(:space)

    Bullet.destroy_if {|bullet| bullet.outside_window? }
    $window.caption = "FPS: #{$window.fps} - GameObjects: #{game_objects.size} - Bullets: #{Bullet.size}"
  end
  
  #
  # setup() is called each time you switch to the game state (and on creation time).
  # You can skip setup by switching with push_game_state(:setup => false) or pop_game_state(:setup => false)
  #
  # This can be useful if you want to display some kind of box above the gameplay (pause/options/info/... box)
  #
  def setup
    # Destroy all created objects of class Bullet
    #p Bullet.size
    #puts Bullet.all
    Bullet.destroy_all
    
    # Place player in a good starting position
    @player.x = $window.width/2
    @player.y = $window.height - @player.image.height
  end
end

#
# SPECIAL GAMESTATE - Pause
#
# NOTICE: Chingu now comes with a predefined Chingu::GameStates::Pause that works simular to this!
#
class Pause < Chingu::GameState
  def initialize(options = {})
    super
    @title = Chingu::Text.create(:text=>"PAUSED (press 'u' to un-pause)", :x=>100, :y=>200, :size=>20, :color => Color.new(0xFF00FF00))
    self.input = { :u => :un_pause }
  end

  def un_pause
    pop_game_state(:setup => false)    # Return the previous game state, dont call setup()
  end
  
  def draw
    previous_game_state.draw    # Draw prev game state onto screen (in this case our level)
    super                       # Draw game objects in current game state, this includes Chingu::Texts
  end  
end

Game.new.show