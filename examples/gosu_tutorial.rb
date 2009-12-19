require 'rubygems'
require 'chingu'
include Gosu
include Chingu
DEBUG = false

class Game < Chingu::Window
  def initialize
    super(640,400)
    self.input = {:esc => :exit}
    
    @player = Player.create(:zorder => 2, :x=>320, :y=>240)
    @score = 0
    @text = Text.create("Score: #{@score}", :x => 10, :y => 10, :zorder => 55, :size=>20)
  end

  def update
    super
    if rand(100) < 4 && Star.all.size < 25
      Star.create
    end
    
    [Player, Star].each_collision(Player, Star) do |player, star| 
      star.destroy
      @score+=10
    end
    
    @text.text = "Score: #{@score}"
    self.caption = "Chingu Game - " + @text.text
  end
end

class Player < GameObject
  has_trait :bounding_circle, :debug => DEBUG
  has_traits :collision_detection, :effect, :velocity
  
  def initialize(options={})
    super(options)
    @image = Image["Starfighter.bmp"]
    self.input = {:holding_right=>:turn_right, :holding_left=>:turn_left, :holding_up=>:accelerate}
    self.max_velocity = 10
  end
  
  def accelerate
    self.velocity_x = Gosu::offset_x(self.angle, 0.5)*self.max_velocity
    self.velocity_y = Gosu::offset_y(self.angle, 0.5)*self.max_velocity
  end
  
  def turn_right
    rotate(4.5)
  end
  
  def turn_left
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
  has_trait :bounding_circle, :debug => DEBUG
  has_traits :collision_detection
  
  def initialize(options={})
    super(:zorder=>1)
    @animation = Chingu::Animation.new(:file => media_path("Star.png"), :size => [25,25])
    @image = @animation.next
    self.color = Gosu::Color.new(0xff000000)
    self.color.red = rand(255 - 40) + 40
    self.color.green = rand(255 - 40) + 40
    self.color.blue = rand(255 - 40) + 40
    self.x =rand * 640
    self.y =rand * 480
    
    cache_bounding_circle
  end
  
  def update
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation.next
  end

end

Game.new.show