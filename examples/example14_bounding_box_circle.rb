require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# Demonstrating Chingu-traits bounding_circle, bounding_box and collision_detection.
#
class Game < Chingu::Window
  def initialize
    super(640,400)
    self.input = {:esc => :exit, :q => :decrease_size, :w => :increase_size, :a => :decrease_speed, :s => :increase_speed}
    
    20.times { Circle.create(:x => width/2, :y => height/2) }
    20.times { Box.create(:x => width/2, :y => height/2) }
    @blue = Color.new(0xFF0000FF)
    @white = Color.new(0xFFFFFFFF)
  end
  
  def increase_size
    game_objects.each { |go| go.factor += 1 }
  end
  def decrease_size
    game_objects.each { |go| go.factor -= 1 if go.factor > 1  }
  end
  def increase_speed
    game_objects.each { |go| go.velocity_x *= 1.2; go.velocity_y *= 1.2; }
  end
  def decrease_speed
    game_objects.each { |go| go.velocity_x *= 0.8; go.velocity_y *= 0.8; }
  end

  def update
    super
    
    game_objects.each { |go| go.color = @white }

    #
    # Collide Boxes/Circles, Boxes/Boxes and Circles/Circles (basicly all objects on screen)
    #
    # Before optmization: 25 FPS  (20 boxes and 20 circles)
    # Cached radius and rects:
    #
    [Box, Circle].each_collision(Box, Circle) { |o, o2| o.color, o2.color = @blue, @blue }
    
    #
    # Only collide boxes with other boxes
    #
    ## Box.each_collision(Box) { |o, o2| o.color, o2.color = @blue, @blue }

    #
    # Only collide circles with other circles
    #
    ## Circle.each_collision(Circle) { |o, o2| o.color, o2.color = @blue, @blue }

    #
    # Only collide Boxes with Boxes and Circles
    #
    ## Box.each_collision(Box,Circle) { |o, o2| o.color, o2.color = @blue, @blue }

    self.caption = "traits bounding_box/circle & collision_detection. Q/W: Size. A/S: Speed. FPS: #{fps} Objects: #{game_objects.size}"
  end
end

class Circle < GameObject
  has_trait :bounding_circle, :debug => true
  has_traits :velocity, :collision_detection
  
  def initialize(options)
    super
    @image = Image["circle.png"]
    self.velocity_x = 3 - rand * 6
    self.velocity_y = 3 - rand * 6
    self.factor = 2
    self.input = [:holding_left, :holding_right, :holding_down, :holding_up]  # NOTE: giving input an Array, not a Hash 
    cache_bounding_circle
  end
  
  def holding_left; @x -= 1; end
  def holding_right; @x += 1; end
  def holding_down; @y += 1; end
  def holding_up; @y -= 1; end
  
  def update
    self.velocity_x = -self.velocity_x  if @x < 0 || @x > $window.width
    self.velocity_y = -self.velocity_y  if @y < 0 || @y > $window.height
  end
end

class Box < GameObject
  has_trait :bounding_box, :debug => true
  has_traits :velocity, :collision_detection
  
  def initialize(options)
    super
    @image = Image["rect.png"]
    self.velocity_x = 3 - rand * 6
    self.velocity_y = 3 - rand * 6
    self.factor = 2
    cache_bounding_box
  end
  
  def update
    self.velocity_x = -self.velocity_x  if @x < 0 || @x > $window.width
    self.velocity_y = -self.velocity_y  if @y < 0 || @y > $window.height
    #@x = @x.to_i
    #@y = @y.to_i
  end
end

Game.new.show