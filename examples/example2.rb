require 'rubygems'
require '../chingu.rb'
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
    @player.keymap = {:left => :move_left, :right => :move_right, :up => :move_up, :down => :move_down, :space => :fire}
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
  # A #super call here would call #update on all Chingu::Actors and check their keymaps, and call the specified method.
  # 
  def update
    
    ### Your own gamelogic here
    
    super
  end
  
end

class Player < Chingu::Actor
  def move_left;  @x -= 1; end
  def move_right; @x += 1; end
  def move_up;    @y -= 1; end
  def move_down;  @y += 1; end
  
  def fire
    Bullet.new(:x => @x, :y => @y)
  end
  
  def update
  end
end

class Bullet < Chingu::Actor
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

Game.new.show