class Player < MyGameObject
  add_component :input
  attr_accessor :speed, :score, :lives, :plasma

  def initialize(options)
    super
		@image = Image["spaceship.png"]
    @radius = (@image.height + @image.width) / 2 * 0.80
    setup
	end
	
  def setup
    self.input = { :holding_left => :turn_left, :holding_right => :turn_right, :space => :fire }
    
    @engine_power = 7
    @health = 100
    @lives = 3
    @score = 0
    @angle_step = 3
    
    # weapons
    @plasma = 1
    @rocket = 0
    @laser = 1
    @autofire = 0
    @current_weapon = :plasma
  end
  
	def turn_left
    @angle -= @angle_step
  end
  def turn_right
    @angle += @angle_step
	end
  
  def bigbomb
    #game_objects_of_class(Enemy).each do |enemy|
    #end
  end
  
  def take(power_up)
    case power_up.type
      when "1up"
        @lives += 1
      when "autofire"
        self.input[:holding_space] = :fire
      when "bigbomb"
        puts "bigbomb"
        bigbomb
      when "plasma_up"
        puts "plasma"
        @plasma += 1  if @plasma < 10
        @current_weapon = :plasma
      when "laser_up"
        puts "laser"
        @laser += 1   if @laser < 10
        @current_weapon = :laser
      when "rocket_up"
        puts "rocket"
        @rocket += 1  if @rocket < 5
    end
  end
  
	def fire    
    # @plasma:
    # 2: start_offset: 5
    # 3: start_offset: 10
    # 4: start_offset: 15        -15, -5, 5, 15
    #
    if @current_weapon == :plasma
      start_offset = (@plasma-1) * 5
      @plasma.times do |nr|
        Bullet.new(:x => @x, :y => @y, :angle => @angle - start_offset + (nr*10), :type => :plasma)
      end
    elsif @current_weapon == :laser
      @plasma.times do |nr|
        Bullet.new(:x => @x, :y => @y, :angle => @angle, :type => :laser)
      end
    end
    
    
  end
	
	def distance_to(object)
		distance(self.x, self.y, object.x, object.y)
	end
	
	def update
    @x += offset_x(@angle, 2)
		@y += offset_y(@angle, 2)
		self
  end
end

class Weapon
  def initialize(weapon_class, power = 1)
    @weapon_class = weapon_class
    @power = power
  end
  
  def fire
    #@weapon_class.new
  end
end

class Bullet < MyGameObject
  def initialize(options)
    super
    @range = options[:range] || 40
    @type = options[:type] || :plasma
		@image = Image["#{@type.to_s}.png"]
		@health = 10
    @speed = 8
    @color = Color.new(255,255,255,255)
    @mode = :additive
    
    Sample["plasma.wav"].play(0.1)
  end
  
  def move
		@x += @speed_x
		@y += @speed_y
  end
  
  def update(time = 1)
    #base = time/100.0
    
    if @type == :laser
      @color.alpha =  ($window.ticks%2 == 0) ? 255 : 0
    end
    
		@speed_x = offset_x(@angle, @speed)
		@speed_y = offset_y(@angle, @speed)
    move
  end  	
end
