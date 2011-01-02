#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# Chingu::Console tries to emulate how Chingu::Window works but without GFX and keyboardinput
#
class Game < Chingu::Console
  
  def update
    super
    sleep(0.02) # fake some cpu intensive game logic :P
    puts "Gameloop running at #{fps} FPS. milliseconds since last tick #{dt}."
  end
  
end

Game.new.show