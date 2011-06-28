#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu

class Game < Chingu::Window
  def initialize
    super(640,480,false)              # leave it blank and it will be 800,600,non fullscreen
    self.input = { :escape => :exit } # exits example on Escape
    
    @player = Player.create(:x => 200, :y => 200, :image => Image["spaceship.png"])
    @player.input = [ :holding_left, :holding_right, :holding_up, :holding_down, :holding_a ]
  end
  
  def update
    super
    self.caption = "FPS: #{self.fps} milliseconds_since_last_tick: #{self.milliseconds_since_last_tick}"
  end
end

class Player < Chingu::GameObject  
  def holding_left;  @x -= 3; end
  def holding_right; @x += 3; end
  def holding_up;    @y -= 3; end
  def holding_down;  @y += 3; end
  def holding_a
    Bullet.create(:x => @x, :y => @y)
  end
end

class Bullet < Chingu::GameObject
  def setup
    @image = Image["fire_bullet.png"]
  end
  
  def update
    @y -= 2
  end
end


Game.new.show