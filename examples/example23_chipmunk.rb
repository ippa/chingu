#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu


class Game < Chingu::Window
  def initialize
    super(640,480,false)              # leave it blank and it will be 800,600,non fullscreen
    self.input = { :escape => :exit } # exits example on Escape    
    
    Player.create(:x => 0, :y => 0, :rotation_center => :top_left)
  end  
end

class Player < BasicGameObject
  trait :sprite, :image => "spaceship.png"
  
  def setup
  end  
end


Game.new.show