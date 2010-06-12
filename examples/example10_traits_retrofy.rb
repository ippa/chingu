#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu
$stderr.sync = $stdout.sync = true

#
# Testing out a new module-only-super-chain trait system
#
class Game < Chingu::Window
  def initialize
    super(600,400)
    self.caption = "Testing out new module-based traits (SPACE for more spaceships)"
    self.input = { :space => :create_thing, :esc => :exit }
		Gosu::enable_undocumented_retrofication
    create_thing(200,200)
  end

  def update
    puts "--- UPDATE ---"
    super
  end
  
  def draw
    puts "--- DRAW ---"
    super
  end
  
  def create_thing(x=nil, y=nil)
    Thing.create(:x => x||rand($window.width), :y => y||rand($window.height), :debug => true)
  end
end

class Thing < Chingu::GameObject
  trait :effect
  trait :velocity
  
  def initialize(options)
    super
    @image = Image["spaceship.png"]
    
    self.rotation_center(:center)

    # Julians ninjahack to get that sweet pixely feeling when zooming :)
    # glBindTexture(GL_TEXTURE_2D, @image.gl_tex_info.tex_name)
    # glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    # glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
    #
    # The above code has been merged into chingu as @image.retrofy
    #
    # @image.retrofy
		#
		# Use Gosu::enable_undocumented_retrofication instead!


    self.scale = 8
    puts "scale: " + scale.to_i.to_s
    self.rotation_rate = 2
    self.velocity_x = 2
  end
  
  def update
    puts "Thing#update"
    if outside_window?
      @velocity_x = -@velocity_x
      self.rotation_rate = -self.rotation_rate
    end
  end
  
  def draw
    puts "Thing#draw"
    super
  end
  
end


Game.new.show
 