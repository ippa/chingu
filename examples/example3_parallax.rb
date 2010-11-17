#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu

#
# Parallax-example
# Images from http://en.wikipedia.org/wiki/Parallax_scrolling
#
class Game < Chingu::Window
  def initialize
    super(600,200)
    self.caption = "Chingu::Parallax example. Scroll with left/right arrows. Space for new parallax example!"
    switch_game_state(Wood)
  end
end

class Scroller < Chingu::GameState
  
  def initialize(options = {})
    super(options)
    @text_color = Color.new(0xFF000000)
    self.input =  { :holding_left => :camera_left, 
                    :holding_right => :camera_right, 
                    :holding_up => :camera_up,
                    :holding_down => :camera_down,
                    :space => :next_game_state,
                    :escape => :exit
                  }    
  end
    
  def next_game_state
    if current_game_state.class == Wood
      switch_game_state(Jungle)
    else
      switch_game_state(Wood)
    end
  end
  
  def camera_left
    # This is essentially the same as @parallax.x += 2
    @parallax.camera_x -= 2
  end
  
  def camera_right
    # This is essentially the same as @parallax.x -= 2
    @parallax.camera_x += 2
  end  

  def camera_up
    # This is essentially the same as @parallax.y += 2
    @parallax.camera_y -= 2
  end

  def camera_down
    # This is essentially the same as @parallax.y -= 2
    @parallax.camera_y += 2
  end  
end

class Wood < Scroller
  def setup
    @parallax = Chingu::Parallax.create(:x => 150, :y => 150, :rotation_center => :top_left)
    @parallax << { :image => "wood.png", :repeat_x => true, :repeat_y => true}
    Chingu::Text.create("82x64 image with repeat_x and repeat_y set to TRUE", :x => 0, :y => 0, :size => 30, :color => @text_color)
  end
end

class Jungle < Scroller
  def initialize(options = {})
    super
    @parallax = Chingu::Parallax.create(:x => 0, :y => 0, :rotation_center => :top_left)
  
    #
    # If no :zorder is given to @parallax.add_layer it defaults to first added -> lowest zorder
    # Everywhere the :image argument is used, theese 2 values are the Same:
    # 1) Image["foo.png"]  2) "foo.png"
    #
    # Notice we add layers to the parallax scroller in 3 different ways. 
    # They all end up as ParallaxLayer-instances internally
    #
    @parallax.add_layer(:image => "Parallax-scroll-example-layer-0.png", :damping => 100)
    @parallax.add_layer(:image => "Parallax-scroll-example-layer-1.png", :damping => 10)
    @parallax << Chingu::ParallaxLayer.new(:image => "Parallax-scroll-example-layer-2.png", :damping => 5, :parallax => @parallax)
    @parallax << {:image => "Parallax-scroll-example-layer-3.png", :damping => 1}
    
    Chingu::Text.create("Multiple layers with repeat_x set to TRUE", :x => 0, :y => 0, :size => 30, :color => @text_color)
  end
end

Game.new.show