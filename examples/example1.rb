require 'rubygems'
require '../lib/chingu.rb'
include Gosu

#
# A minimalistic Chingu example.
# Chingu::Window provides #update and #draw which calls corresponding methods for all objects based on Chingu::Actors
#
# Image["picture.png"] is a deploymentsafe shortcut to Gosu's Image.new and supports multiple locations for "picture.png"
# By default current dir, media\ and gfx\ is searched. To add own directories:
#
# Image.autoload_dirs << File.join(self.root, "data", "my_image_dir")  
# 
class Game < Chingu::Window
  def initialize
    super 
    @player = Player.new(:x => 200, :y => 200, :image => Image["spaceship.png"])
    @player.input = { :holding_left => :move_left, :holding_right => :move_right, 
                      :holding_up => :move_up, :holding_down => :move_down}
  end
  
  def update
    super
    self.caption = "FPS: #{self.fps} milliseconds_since_last_tick: #{self.milliseconds_since_last_tick}"
  end
end

class Player < Chingu::GameObject
  def move_left;  @x -= 1; end
  def move_right; @x += 1; end
  def move_up;    @y -= 1; end
  def move_down;  @y += 1; end
end


Game.new.show