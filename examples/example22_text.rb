#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu


class Game < Chingu::Window
  def initialize
    super(640,480,false)              # leave it blank and it will be 800,600,non fullscreen
    self.input = { :escape => :exit } # exits example on Escape    
    self.caption = "Demonstration of Text"
    push_game_state(Woff)
  end  
end

class Woff < GameState
  def setup
    self.input = { [:space, :esc] => :exit }
    
    
    # Some Text with adapting :background 
    Text.create("tiny", :x => 200, :y => 200, :size => 20, :background => "talk_bubble.png", :color => Color::BLACK)
    
    Text.size = 50
    Text.padding = 20
    Text.create("Hello", :x => 100, :y => 30, :background => "talk_bubble.png", :color => Color::BLACK)
    Text.create("YES YOU! Bla bla bla bla.", :size => 40, :x => 200, :y => 300, :background => "talk_bubble.png", :color => Color::BLACK)
    
    #
    # TODO: More text examples!
    # 
  end
  
  def draw
    fill_gradient(:from => Color::CYAN, :to => Color::BLUE)
    super
  end
end


Game.new.show