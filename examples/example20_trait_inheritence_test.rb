#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu

#
# This is more of a technical test to sort out the class inheritable accessor ..
# ..more then it's a fun-to-watch demo.
#
class Game < Chingu::Window
  def initialize
    super    
    self.input = { :escape => :exit }
		
		star = SpinningStar.create(:x => 400, :y => 100)
		star2 = MovingStar.create(:x => 10, :y => 200)
		
		p star.class.superclass
		p "=== Should only have collision detection"
		p star.class
		p star.class.trait_options
		p "=== Should have collision detection and velocity"
		p star2.class
		p star2.class.trait_options
  end
end


class Star < GameObject
  trait :collision_detection
  
  def initialize(options={})
    super
    
    @animation = Chingu::Animation.new(:file => "Star.png", :size => 25)
    @image = @animation.next
  end
  
end

class MovingStar < Star
	trait :velocity
	
  def initialize(options={})
		super
		self.velocity_x = 1
  end	
end

class SpinningStar < Star
  def update
    @image = @animation.next
  end
end	
	

Game.new.show