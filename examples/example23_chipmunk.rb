#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu


class Game < Chingu::Window
  def initialize
    super(640,480,false)              # leave it blank and it will be 800,600,non fullscreen
    self.input = { :escape => :exit } # exits example on Escape    
    
    Player.create(:x => 0, :y => 0, :rotation_center => :top_left)
    Text.create("NOTHING TO SEE HERE YET ;-)", :align => :center)
  end  
end

class Player < BasicGameObject
  trait :sprite, :image => "spaceship.png"
  
  def setup
  end  
end


Game.new.show