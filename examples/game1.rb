#!/usr/bin/env ruby
#
#
# A simple game in Chingu, using GameState, GameObject, Paralaxx, has_traits etc
# 
#
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
require 'texplay'     # adds Image#get_pixel

include Gosu
include Chingu

class Game < Chingu::Window  
  def initialize
    super(1000,400,false)
    self.input = { :escape => :exit }
		retrofy
    switch_game_state(Level)
  end
end


#
# GAME STATE: LEVEL
#
class Level < Chingu::GameState
  has_trait :timer
  
  def initialize(options = {})
    super

    @parallax = Parallax.create(:rotation_center => :top_left, :zorder => 200)
    @parallax << { :image => "city2.png", :damping => 2, :zorder => 200}
    @parallax << { :image => "city1.png", :damping => 1, :zorder => 900}
    
    @player = Player.create(:x => 30, :y => 10, :zorder=> 500)
    
    @bg1 = Color.new(0xFFCE28FF)
    @bg2 = Color.new(0xFF013E87)
  end
  
  #
  # This is called each time this GameState is switched/pushed/poped to.
  #
  def setup
    # Remove all lingering game objects
    Enemy.destroy_all
    Bullet.destroy_all
    
    @player.score = 0
    @player.x = 10
    @player.y = 100
    
    @parallax.camera_x = 0
    @total_game_ticks = 10000#100000
    @timer = 100
    @total_ticks = 0
  end

  #
  # The foremost layer in our parallax scroller is the collidable terrain
  #
  def solid_pixel_at?(x, y)
    begin     
      @parallax.layers.last.get_pixel(x, y)[3] != 0
    rescue
      puts "Error in get_pixel(#{x}, #{y})"
    end
  end
  
  def update
    super
    
    # Move the level forward by increasing the parallax-scrollers camera x-coordinate
    @parallax.camera_x += 1
    
    # Remove all objects outside screen
    game_objects.destroy_if { |game_object| game_object.respond_to?("outside_window?") && game_object.outside_window? }

    # Collide bullets with terrain
    Bullet.select { |o| solid_pixel_at?(o.x, o.y)}.each { |o| o.die }
        
    # Collide player with terrain
    push_game_state(GameOver) if solid_pixel_at?(@player.x, @player.y)
    
    # Collide player with enemies and enemy bullets
    @player.each_bounding_circle_collision(Enemy) do |player, enemy|
      enemy.die
      push_game_state(GameOver)
    end
    
    Bullet.each_bounding_circle_collision(Enemy) do |bullet, enemy|
      bullet.die
      if enemy.hit_by(bullet)
        @player.score += 20
      end
    end
    
    @timer = @timer * 0.9999
    @total_ticks += 1
    if @total_ticks > @timer
      Enemy.create(:x => $window.width, :y => rand(300))
      @total_ticks = 0
    end
        
    #$window.caption = "City Battle! Player x/y: #{@player.x}/#{@player.y} - Score: #{@player.score} - FPS: #{$window.fps} - game objects: #{game_objects.size}"
  end
  
  def draw
    fill_gradient(:from => @bg2, :to => @bg1)
    @parallax.draw
    super    
  end
end

#
# OUR PLAYER
#
class Player < GameObject
  has_traits :velocity, :collision_detection, :timer
  has_trait :bounding_circle, :scale => 0.50, :debug => false
  attr_accessor :score
  
  def setup
    @image = Image["plane.png"]
    
    self.input = {
      :holding_left => :left, 
      :holding_right => :right, 
      :holding_up => :up, 
      :holding_down => :down, 
      :holding_space => :fire }
    
    @max_velocity = 2
    @score = 0
    @cooling_down = false
  end
  	
  def up
    self.velocity_y = -@max_velocity
  end
  def down
    self.velocity_y = @max_velocity
  end
  def right
    self.velocity_x = @max_velocity
  end
  def left
    self.velocity_x = -@max_velocity
  end
  
  def fire
    return if @cooling_down
    @cooling_down = true
    after(100) { @cooling_down = false }
    
    Bullet.create(:x => self.x, :y => self.y)
    Sound["laser.wav"].play(0.1)
  end
  
  def update
    self.velocity_y *= 0.6
    self.velocity_x *= 0.6
    
    @x = @last_x  if @x < 0 || @x > $window.width
    @y = @last_y  if @y < 0 || @y > $window.height
    @last_x, @last_y = @x, @y
  end
  
end

#
# OUR PLAYERS BULLETS
#
class Bullet < GameObject
  has_traits :timer, :collision_detection, :velocity
  attr_reader :status, :radius
  
  def setup
    @image = Image["bullet.png"]
    self.velocity_x = 10
    @status = :default
    @radius = 3
  end
  
  def die
    return  if @status == :dying
    Sound["bullet_hit.wav"].play(0.2)
    @status = :dying
    during(50) { @factor_x += 1; @factor_y += 1; @x -= 1; }.then { self.destroy }
  end
  
end

#
# ENEMY BULLET
#
class EnemyBullet < Bullet
  def setup
    @image = Image["enemy_bullet.png"]
    self.velocity_x = -3
  end
end

class Explosion < GameObject
  has_traits :timer
  
  def initialize(options)
    super
    
    unless defined?(@@image)
      @@image = TexPlay::create_blank_image($window, 100, 100)
      @@image.paint { circle 50,50,49, :fill => true, :color => [1,1,1,1] }
    end
    
    @image = @@image.dup  if @image.nil?
    
    self.rotation_center = :center
    during(100) { self.alpha -= 30}.then { destroy }
  end
  
  def self.create_image_for(object)
    width = height = (object.image.width + object.image.height) / 2
    explosion_image = TexPlay::create_blank_image($window, 100, 100)
    explosion_image.paint { circle 50,50,49, :fill => true, :color => [1,1,1,1] }
    return explosion_image
  end
  
end

class Shrapnel < GameObject
  has_traits :timer, :effect, :velocity
  
  #def initialize(options)
  #  super
  def setup
    self.rotation_rate = 1 + rand(10)
    self.velocity_x = 4 - rand(8)
    self.velocity_y = 4 - rand(10)
    self.acceleration_y = 0.2 # gravity = downards acceleration
    self.rotation_center = :center
    @status = :default
  end
  
  def self.create_image_for(object)
    image = object.image
    width = image.width / 5
    height = image.width / 5
    
    shrapnel_image = TexPlay::create_blank_image($window, width, height)
    x1 = rand(image.width/width)
    y1 = rand(image.height/height)
    shrapnel_image.paint { splice image,0,0, :crop => [x1, y1, x1+width, y1+height] }    
    
    return shrapnel_image
  end
  
  def die
    destroy
  end
  
end

#
# OUR ENEMY SAUCER
#
class Enemy < GameObject
  has_traits :collision_detection, :timer  
  attr_reader :radius
  
  def setup
    @velocity = options[:velocity] || 2
    @health = options[:health] || 100
    
    @anim = Animation.new(:file => "media/saucer.png", :size => [32,13], :delay => 100)
    @image = @anim.first
      
    @radius = 5
    @black = Color.new(0xFF000000)
    @status == :default
    
    #
    # Cache explosion and shrapnel images (created with texplay, not recomended doing over and over each time)
    #
    @@shrapnel_image ||= Shrapnel.create_image_for(self)
    @@explosion_image ||= Explosion.create_image_for(self)
  end
  
  def hit_by(object)
    return if @status == :dying
    
    #
    # During 20 millisecons, use Gosus :additive draw-mode, which here results in a white sprite
    # Classic "hit by a bullet"-effect
    #
    during(20) { @mode = :additive; }.then { @mode = :default }
    
    @health -= 20
  
    if @health <= 0
      die
      return true
    else
      return false
    end
  end
  
  def fire
    EnemyBullet.create(:x => self.x, :y => self.y)
  end
  
  def die
    #
    # Make sure die() is only called once
    #
    return  if @status == :dying
    @status = :dying
    
    #
    # Play our explosion-sound file
    # Create an explosion-object
    # Create some shrapnel-objects
    #
    Sound["explosion.wav"].play(0.3)
    Explosion.create(:x => @x, :y => @y, :image => @@explosion_image )
    5.times { Shrapnel.create(:x => @x, :y => @y, :image => @@shrapnel_image)}
    
    #
    # During 200 ms, fade and scale image, then destroy it
    #
    @color = @black
    @color.alpha = 50
    during(200) { @factor_x += 0.5; @factor_y += 0.5; @x -= 1; @color.alpha -= 1}.then { self.destroy }
  end
  
  def update
    return if @status == :dying
    
    @image = @anim.next
    @x -= @velocity
  end
end


#
# GAME STATE: GAME OVER
#
class GameOver < Chingu::GameState  
  def setup
    @text = Text.create("GAME OVER (ESC to quit, RETURN to try again!)", :size => 40, :x => 30, :y => 100)
    self.input = { :esc => :exit, :return => :try_again }
    @layover = Color.new(0x99000000)
  end
  
  def draw
    super
    previous_game_state.draw
    fill(@layover)
  end
  
  def try_again
    pop_game_state  # pop back to our playing game state
  end
end

#
# GAME STATE: GAME OVER
#
class Done < Chingu::GameState
  def initialize(options)
    @score = options[:score]
  end
  
  def setup
    @text = Text.create("You made it! Score #{@score} (ESC to quit, RETURN to try again!)", :size => 40, :x => 30, :y => 100)
    self.input = { :esc => :exit, :return => :try_again}
  end  
  
  def try_again
    pop_game_state  # pop back to our playing game state
  end
end


Game.new.show
