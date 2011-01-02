#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

class Game < Chingu::Window
  def initialize
    super(800,400,false)              # leave it blank and it will be 800,600,non fullscreen
    self.input = { :escape => :exit } # exits example on Escape    
    self.caption = "Demonstration of GameStates::EnterName"
    push_game_state(GameStates::EnterName.new(:callback => method(:got_name)))
  end
  
  def got_name(name)
    puts "Got name: #{name}"
    exit
  end
end

Game.new.show