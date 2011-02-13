#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu
$stderr.sync = $stdout.sync = true

Chingu::Text.trait :asynchronous

class BadGuy < Chingu::GameObject
  trait :asynchronous
  
  def fire!
    # Create a text object to represent shooting sounds.
    text = Chingu::Text.create("Pew!", :x => x, :y => y - height)
    
    # Now, make that text object fade out and disappear asynchronously.
    text.async do |q|
      q.tween(750, :alpha => 0, :scale => 2)
      q.call :destroy
    end
  end
  
end

class Game < Chingu::Window
  
  def initialize
    super 480, 240, false
    
    self.caption = "Press [SPACE] to run the demo"
    
    # Create our bad guy!
    @boss = BadGuy.create :image => 'Starfighter.bmp'
    
    # Instruct the boss to move along a path while rotating clockwise.
    # Nothing is actually done until the run loop calls #update.
    @boss.async do |q|
      # These tasks are performed sequentially and asynchronously
      # using the magic of queues. Each GameObject has its own!
      q.wait { button_down? Gosu::KbSpace }
      q.tween(1000, :x => 100, :y => 100, :angle => 45)
      q.tween(1000, :y => 200, :angle => 90)
      q.call :fire!
    end
    
    # Single tasks can also be given with a less verbose syntax.
    # Wait a second...
    @boss.async.wait 1000
    
    # Move and fire one more time, just for good measure.
    @boss.async do |q|
      q.tween(1000, :x => 200, :y => 100, :angle => 360)
      3.times do
        q.wait 500
        q.call :fire!
      end
    end
    
  end
  
end

Game.new.show
