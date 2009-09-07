class EnemyTemplate < MyGameObject
  attr_reader :speed_x, :speed_y
	#attr_accessor :prev_x, :prev_y, :aim_x, :aim_y
    
	def initialize(options = {})
    super
    @image = Image["enemy.png"]
    
    @type = options[:type] || 0
    @reaction = options[:reaction] || 0.1
    
		@prev_x, @prev_y = @x, @y
    @speed_x = @speed_y = 0.0
		@acceleration_x = @acceleration_y = 0.0
		
    @keep_color_for = 0	
		@rad_to_deg = 180 / Math::PI
  end
  
  def setup
    @factor_x = @width.to_f / @image.width.to_f
    @factor_y = @height.to_f / @image.height.to_f
    self.factor = (@factor_x < @factor_y) ? @factor_x : @factor_y
    
    @radius = (@width + @height) / 2 * 0.50
    @original_color = @color
  end

	def aim_at(x, y)
    if @status != :dying
      @aim_x, @aim_y = x, y
      @angle = Math.atan2(@aim_y - @y, @aim_x - @x).to_f * @rad_to_deg
      @angle = 90 + @angle
      
      @acceleration_y = (@y - @aim_y < 0) ? @reaction : -@reaction
      @acceleration_x = (@x - @aim_x < 0) ? @reaction : -@reaction
    end
		self
	end
  
  def damage(punch)
    super
    if @status != :dying
      Sound["hit3.wav"].play(0.1, 0.3 + rand(10)/20.to_f)
      @color = Gosu::Color.new(255,255,255,255)
      @keep_color_for = $window.ticks + 5
    end
  end
    
	def die!
    Sound["explosion.wav"].play(0.1, 1.0 + rand(0.5))
    @image = Image["enemy_dying.png"]
    @status = :dying
    @color = @original_color
    @color.alpha = 100
  end
  
	def update
    if @status == :dying
      @factor_x += 0.4
      @factor_y -= 0.2    if @factor_y > 0.2
      @color.alpha -= 10  if @color.alpha > 10
    else
      @speed_y += @acceleration_y		if	(@speed_y + @acceleration_y).abs < @max_speed
      @acceleration_y = 0	if @speed_y == 0

      @speed_x += @acceleration_x		if	(@speed_x + @acceleration_x).abs < @max_speed
      @acceleration_x = 0	if @speed_x == 0
      move
    end
    
    if @factor_x > 3
      @status = :dead
      $window.remove_game_object(self)
    end
    
    @color = @original_color  if @color != @original_color && $window.ticks > @keep_color_for
    
		self
	end	
  
  def move
    base = $window.dt/100.0
		@prev_x, @prev_y = @x, @y
		@x += @speed_x * base
    @y += @speed_y * base
  end
end
  

class Enemy < EnemyTemplate
  def initialize(options)
    super
    
    @type = options[:type] || 0
    case @type
      when 0
        @width = 40 
        @height = 30
        @reaction = 0.01
        @punch = 40
        @health = 40
        @max_speed = 4
        @color = Gosu::Color.new(255,0,255,0)
      when 1
        @width = 80
        @height = 60
        @reaction = 0.02
        @punch = 80
        @health = 80
        @max_speed = 10
        @color = Gosu::Color.new(255,255,255,0)
    end
    
    setup
  end
end
