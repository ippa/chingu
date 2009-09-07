class PowerUp < Chingu::GameObject
  attr_reader :type, :radius, :status
  
  def initialize(options)
    super
    @speed_x = options[:speed_x] 
    @speed_y = options[:speed_y]
    @type = options[:type]

    @powerup_bg = Image["powerup_bg.png"]
    @powerup = Image["#{@type}.png"]
    #@image = Image["#{@type}.png"]
    
    @radius = (@powerup_bg.width + @powerup_bg.height) / 2 * 0.70
        
    @white = Gosu::Color.new(150,255,255,255)
    @transparent = Gosu::Color.new(255,255,255,255)
    @status = :default
    
    @zoom_seed_x = 0
    @zoom_seed_y = Math::PI    
  end

  #
  # Creates a powerup with objects x/y-coords and speed_x/speed_y
  #
  def self.new_from(object)
    power_ups = ["plasma_up", "1up", "laser_up", "rocket_up", "bigbomb", "autofire"]
    type = power_ups[rand(power_ups.size)]
    PowerUp.new(:type => type, :x => object.x, :y => object.y,
                :speed_x => object.speed_x, :speed_y => object.speed_y)
  end

  def die!
    @status = :dead
    destroy!
    ##$window.remove_game_object(self)
  end
  def alive?
    @status == :default
  end
  def dead?
    @status == :dead
  end
  
  def update
    self.factor_x = 1.1 + Math::sin(@zoom_seed_x += 0.3)/20
    self.factor_y = 1.1 + Math::sin(@zoom_seed_y += 0.3)/20
  end
  
  def draw
    @color = @transparent
    @image = @powerup_bg
    super
    @image = @powerup
    #@color = ($window.ticks % 2 == 0) ? @white : @transparent
    super
  end
  
  private
  
  def move
    base = $windows.dt/100.0
    @x += @speed_x * base
    @y += @speed_y * base
  end
end
