require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu

#
# A little more complicated example where we do our own #update and #draw code.
# We also add another Actor - a bullet fired with space.
#
# Also tests out the Debug game state.
#
class Game < Chingu::Window
  def initialize
    #
    # See http://www.libgosu.org/rdoc/classes/Gosu/Window.html#M000034 for options
    # By default Chingu does 640 x 480 non-fullscreen.
    #
    super
    
    push_game_state(Play)
  end
end

#
# Our Player
#
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
    Bullet.create(:x => @x, :y => @y)
  end  
end

class Bullet < Chingu::GameObject
  #
  # If we need our own initialize, just call super and Chingu does it's thing.
  # Here we merge in an extra argument, specifying the bullet-image.
  #
  def initialize(options)
    super(options.merge(:image => Image["fire_bullet.png"]))
  end

  # Move the bullet forward
  def update
    @y -= 2
  end
  
end

class Play < Chingu::GameState
  
  def initialize
    super
    @player = Player.create(:x => 200, :y => 200)
    @player.input = { :holding_left => :move_left, 
                      :holding_right => :move_right, 
                      :holding_up => :move_up, 
                      :holding_down => :move_down, 
                      :space => :fire,
                      :escape => :exit,
                      }
    self.input = { :f1 => :debug }
  end
  
  def debug
    #puts "--------"
    #GameObject.all.each do |game_object|
    #  puts game_object.class
    #end
    #return 
    
    push_game_state(Chingu::GameStates::Debug)
  end
    
  #
  # If we want to add extra graphics drawn just define your own draw.
  # Be sure to call #super for enabling Chingus autodrawing of Actors.
  # Putting #super before or after the background-draw-call really doesn't matter since Gosu work with "zorder".
  #
  def draw
    # Raw Gosu Image.draw(x,y,zorder)-call
    Image["background1.png"].draw(0, 0, 0)    
    super
  end

  #
  # Gosus place for gamelogic is #update in the mainwindow
  #
  # A #super call here would call #update on all Chingu::Actors and check their inputs, and call the specified method.
  # 
  def update
    Bullet.destroy_if { |bullet| bullet.outside_window? }
    #Bullet.destroy_if(&:outside_window?)
    
    #
    # Bullet.each_collision(Enemy) do |bullet, enemy|
    #   enemy.collision_with(bullet)
    #   bullet.destroy!
    # end
    #
      
    super
    $window.caption = "FPS: #{$window.fps} - milliseconds_since_last_tick: #{$window.milliseconds_since_last_tick} - game objects# #{current_game_state.game_objects.size} Bullets# #{Bullet.size}"
  end  
end

Game.new.show