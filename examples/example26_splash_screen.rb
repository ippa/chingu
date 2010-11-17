#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu

#
# Creates a window, then lets the user change to another one. Use this to change resolution or change to/from
# full-screen mode
#
class SplashScreen < Chingu::Window
  def initialize
    super(400,200,false)
    self.input = { :escape => :close, :return => :load } # exits example on Escape

    Chingu::GameObject.create(:x => 200, :y => 100, :image => Image["spaceship.png"])
    Chingu::Text.create("Press <return> to load game", :y => 100)
  end

  def update
    super
    self.caption = "FPS: #{self.fps} milliseconds_since_last_tick: #{self.milliseconds_since_last_tick}"
  end

  def load
    # MUST close current window before we open the new one!
    close
    MainGame.new.show
  end
end

class MainGame < Chingu::Window
  def initialize
    super(640,480,false)
    self.input = { :escape => :close } # exits example on Escape

    Chingu::GameObject.create(:x => 200, :y => 200, :image => Image["spaceship.png"])
    Chingu::Text.create("Main game loaded", :y => 100)
  end

  def update
    super
    self.caption = "FPS: #{self.fps} milliseconds_since_last_tick: #{self.milliseconds_since_last_tick}"
  end
end


SplashScreen.new.show