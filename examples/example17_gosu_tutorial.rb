#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu

# Set to true to see bounding circles used for collision detection
DEBUG = false

class Game < Chingu::Window
  def initialize
    super(640,400)
    self.input = {:esc => :exit}
    
    @player = Player.create(:zorder => 2, :x=>320, :y=>240)
    @score = 0
    @score_text = Text.create("Score: #{@score}", :x => 10, :y => 10, :zorder => 55, :size=>20)
  end

  def update
    super

    if rand(100) < 4 && Star.all.size < 25
      Star.create
    end
    
    #
    # Collide @player with all instances of class Star
    #
    @player.each_collision(Star) do |player, star| 
      star.destroy
      @score+=10
    end
    
    @score_text.text = "Score: #{@score}"
    self.caption = "Chingu Game - " + @score_text.text
  end
end

class Player < GameObject
  trait :bounding_circle, :debug => DEBUG
  traits :collision_detection, :effect, :velocity
  
  def initialize(options={})
    super(options)
    @image = Image["Starfighter.bmp"]
    self.input = {:holding_right=>:turn_right, :holding_left=>:turn_left, :holding_up=>:accelerate}
    self.max_velocity = 10
  end
  
  def accelerate
    self.velocity_x = Gosu::offset_x(self.angle, 0.5)*self.max_velocity_x
    self.velocity_y = Gosu::offset_y(self.angle, 0.5)*self.max_velocity_y
  end
  
  def turn_right
    # The same can be achieved without trait 'effect' as: self.angle += 4.5
    rotate(4.5)
  end
  
  def turn_left
    # The same can be achieved without trait 'effect' as: self.angle -= 4.5
    rotate(-4.5)
  end
  
  def update
    self.velocity_x *= 0.95 # dampen the movement
    self.velocity_y *= 0.95
    
    @x %= $window.width # wrap around the screen
    @y %= $window.height
  end
end

class Star < GameObject
  trait :bounding_circle, :debug => DEBUG
  trait :collision_detection
  
  def initialize(options={})
    super(:zorder=>1)
    @animation = Chingu::Animation.new(:file => media_path("Star.png"), :size => 25)
    @image = @animation.next
    self.color = Gosu::Color.new(0xff000000)
    self.color.red = rand(255 - 40) + 40
    self.color.green = rand(255 - 40) + 40
    self.color.blue = rand(255 - 40) + 40
    self.x =rand * 640
    self.y =rand * 480
    
    #
    # A cached bounding circle will not adapt to changes in size, but it will follow objects X / Y
    # Same is true for "cache_bounding_box"
    #
    cache_bounding_circle
  end
  
  def update
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation.next
  end
end

Game.new.show