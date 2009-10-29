#
#
# A "full" simple game in Chingu, using GameState, GameObject, Paralaxx, has_traits etc
# 
# TODO: clean up code as Chingu moves along :). Comments.
#
#
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")

require 'texplay'     # adds Image#get_pixel
#require 'devil/gosu'  # adds Gosu::Window#screenshot and better file support
require 'opengl'      # adds raw gl stuff so Image#retrofy works (in some setups this seems to be 'gl')

include Gosu
include Chingu

class Game < Chingu::Window
  attr_reader :factor
  
  def initialize
    super(1000,800,false)
    self.input = { :escape => :exit }
    @factor = 2
    switch_game_state(Level)
  end
end

#
# GAME STATE: GAME OVER
#
class GameOver < Chingu::GameState  
  def setup
    @text = Text.create(:text => "GAME OVER (ESC to quit, RETURN to try again!)", :size => 40, :x => 30, :y => 100)
    self.input = { :esc => :exit, :return => :try_again}
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
    @text = Text.create(:text => "You made it! Score #{@score} (ESC to quit, RETURN to try again!)", :size => 40, :x => 30, :y => 100)
    self.input = { :esc => :exit, :return => :try_again}
  end  
  
  def try_again
    pop_game_state  # pop back to our playing game state
  end
end


#
# GAME STATE: LEVEL
#
class Level < Chingu::GameState
  def initialize(options = {})
    super
    
    @parallax = Parallax.create
    ParallaxLayer.has_trait :retrofy
    @parallax << ParallaxLayer.new(:image => Image["city2.png"].retrofy, :center => 0, :damping => 5, :factor => $window.factor)
    @parallax << ParallaxLayer.new(:image => Image["city1.png"].retrofy, :center => 0, :damping => 1, :factor => $window.factor)
    @player = Player.create(:x => 10, :y => 100)
    
    @bg1 = Color.new(0xFFCE28FF)
    @bg2 = Color.new(0xFF013E87)
  end
  
  #
  # This is called each time this GameState is switched/pushed/poped to.
  #
  def setup
    # Remove all lingering g
    Enemy.destroy_all
    Bullet.destroy_all
    
    @player.score = 0
    @player.x = 10
    @player.y = 100
    
    @parallax.camera_x = 0
    @total_game_ticks = 100000
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
    game_objects.destroy_if { |game_object| game_object.respond_to?("outside_screen?") && game_object.outside_screen? }
    
    # Collide shrapnel with terrain
    ## Shrapnel.all.select { |o| solid_pixel_at?(o.x, o.y)}.each { |o| o.die }


    # Collide bullets with terrain
    Bullet.all.select { |o| solid_pixel_at?(o.x, o.y)}.each { |o| o.die }
        
    # Collide player with terrain
    push_game_state(GameOver) if solid_pixel_at?(@player.x, @player.y)
    
    # Collide player with enemies and enemy bullets
    @player.each_radius_collision(Enemy) do |player, enemy|
      enemy.die
      push_game_state(GameOver)
    end
    
    Bullet.each_radius_collision(Enemy) do |bullet, enemy|
      bullet.die
      if enemy.hit_by(bullet)
        @player.score += 20
      end
    end
    
    
    @timer = @timer * 0.9999
    @total_ticks += 1
    if @total_ticks > @timer
      Enemy.create(:x => $window.width/2, :y => rand(300))
      @total_ticks = 0
    end
    
    #push_game_state(Done.new(:score => @player.score)) if @game_steps == 1
    
    $window.caption = "City Battle! Score: #{@player.score} .... FPS: #{$window.fps}"
  end
  
  def draw
    fill_gradient(:from => @bg2, :to => @bg1)
    super    
  end
end

#
# OUR PLAYER
#
class Player < GameObject
  has_trait :velocity, :collision_detection, :retrofy, :timer
  attr_accessor :score
  
  def initialize(options = {})
    super
    @image = Image["plane.png"].retrofy
    self.factor = $window.factor
    
    self.input = { 
      :holding_left => :left, 
      :holding_right => :right, 
      :holding_up => :up, 
      :holding_down => :down, 
      :holding_space => :fire }
    
    @max_velocity = 1
    @radius = 10
    @score = 0
    @cooling_down = false
  end
  
  def up
    @velocity_y += -@max_velocity
  end
  def down
    @velocity_y += @max_velocity
  end
  def right
    @velocity_x += @max_velocity
  end
  def left
    @velocity_x -= @max_velocity
  end
  
  def fire
    return if @cooling_down
    @cooling_down = true
    after(100) { @cooling_down = false}
    
    Bullet.create(:x => self.x, :y => self.y)
    Sound["laser.wav"].play
  end
  
  def update
    @velocity_y *= 0.6
    @velocity_x *= 0.6
    
    @x = @last_x  if @x < 0 || @x > $window.width/$window.factor
    @y = @last_y  if @y < 0 || @y > $window.height/$window.factor
    @last_x, @last_y = @x, @y
  end
  
end

#
# OUR PLAYERS BULLETS
#
class Bullet < GameObject
  has_trait :retrofy, :timer, :collision_detection
  attr_reader :status
  
  def initialize(options)
    super
    @image = Image["bullet.png"].retrofy
    self.factor = $window.factor
    @velocity_x = 10
    @status = :default
    @radius = 3
  end
  
  def die
    return  if @status == :dying
    Sound["bullet_hit.wav"].play
    @status = :dying
    during(50) { @factor_x += 1; @factor_y += 1; @x -= 1; }.then { self.destroy }
  end
  
  def update
    return if @status == :dying
    @x += @velocity_x
  end
end

#
# ENEMY BULLET
#
class EnemyBullet < Bullet
  def initialize(options)
    super
    @image = Image["enemy_bullet.png"].retrofy
    @velocity_x = -3
  end
end

class Explosion < GameObject
  has_trait :timer,:retrofy
  
  def initialize(options)
    super
    
    unless defined?(@@image)
      @@image = TexPlay::create_blank_image($window, 100, 100)
      @@image.paint { circle 50,50,49, :fill => true, :color => [1,1,1,1] }
    end
    
    @image = @@image.dup  if @image.nil?
    
    
    self.rotation_center(:center)
    self.factor = options[:factor] ? options[:factor] : $window.factor
    during(100) { self.alpha -= 30}.then { destroy }
  end
  
end

class Shrapnel < GameObject
  has_trait :retrofy, :timer, :effect, :velocity
  
  def initialize(options)
    super
    
    @exploding_image = options[:exploding_image]
    
    #
    # Create an image from a random part of the original image (on our case the exploding_image)
    #
    width = 10
    height = 10
    
    @image = TexPlay::create_blank_image($window, width, height)
    x1 = rand(@exploding_image.width/width)
    y1 = rand(@exploding_image.height/height)
    @image.paint { splice @exploding_image,0,0, :crop => [x1, y1, x1+width, y1+height] }
    
    unless defined?(@@explosion)
      @@explosion = TexPlay::create_blank_image($window, width, height)
      @@explosion.paint { circle width/2,height/2,width/3, :fill => true, :color => [1,1,1,1] }
    end
    
    self.rotation_rate = 1 + rand(10)
    self.velocity_x = 4 - rand(8)
    self.velocity_y = 4 - rand(10)
    self.acceleration_y = 0.2 # gravity = downards acceleration
    
    rotation_center(:center)
    self.factor = $window.factor
    @status = :default
  end
  
  def die    
    Explosion.create(:x => @x, :y => @y, :image => @@explosion.dup)
    destroy
  end
  
end

#
# OUR ENEMY SAUCER
#
class Enemy < GameObject
  has_trait :collision_detection, :retrofy, :timer  

  def initialize(options)
    super
    @velocity = options[:velocity] || 2
    @health = options[:health] || 100
    
    @anim = Animation.new(:file => "media/saucer.png", :size => [32,13], :delay => 100)
    @anim.retrofy
    @image = @anim.first
      
    self.factor = $window.factor
    @radius = 5
    @black = Color.new(0xFF000000)
    @status == :default
  end
  
  def hit_by(object)
    return if @status == :dying
    
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
    return  if @status == :dying
    Sound["explosion.wav"].play
    Explosion.create(:x => @x, :y => @y)
    5.times { Shrapnel.create(:x => @x, :y => @y, :exploding_image => self.image)}
    
    @status = :dying
    @color = @black
    @color.alpha = 50
    during(200) { @factor_x += 0.5; @factor_y += 0.5; @x -= 1; @color.alpha -= 1}.then { self.destroy }
  end
  
  def update
    return if @status == :dying
    
    @image = @anim.next!
    @x -= @velocity
  end
end

Game.new.show