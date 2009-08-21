require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu

#
# A little more complicated example where we do our own #update and #draw code.
# We also add another Actor - a bullet fired with space.
#
class Game < Chingu::Window
  def initialize
    #
    # See http://www.libgosu.org/rdoc/classes/Gosu/Window.html#M000034 for options
    # By default Chingu does 640 x 480 non-fullscreen.
    #
    super
    
    @player = Player.new(:x => 200, :y => 200, :image => Image["spaceship.png"])
    @player.input = { :holding_left => :move_left, 
                      :holding_right => :move_right, 
                      :holding_up => :move_up, 
                      :holding_down => :move_down, 
                      :space => :fire,
                      :escape => :exit
                      }
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
    
    ### Your own gamelogic here
    super
    self.caption = "FPS: #{self.fps} milliseconds_since_last_tick: #{self.milliseconds_since_last_tick}"
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
    Bullet.new(:x => @x, :y => @y)
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
  def update(time)
    @y -= 2
  end
  
end

Game.new.show