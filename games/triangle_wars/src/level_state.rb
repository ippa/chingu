class Level < Chingu::GameState
  def initialize(options)
    super
		@player = Player.new({})
    @level = options[:level] || 1
    self.input = { :p => Pause, :f1 => :power_up }

    @score = Text.new(:text => "Score: #{@player.score}  Lives: #{@player.lives}", :x => 10, :y => 4, :size => 30)
  end
  
  def setup
    # If we're starting from the beginning, initialize playerstuffz
    if options[:level] == 1
      @player.setup
    end
    
    @player.x = $window.width/2
    @player.y = $window.height/2
  end
  
  def power_up
    #PowerUp.new(:type=>"plasma_up", :x=>50, :y=>50, :speed_x=>3, :speed_y=>3)
    @player.laser += 1
  end
                
  def random_entry_point
    x, y = 0
    if rand(2)==0
      x = rand(2)==0 ? 1 : $window.width
      y = rand($window.height)
    else
      x = rand($window.width)
      y = rand(2)==0 ? 1 : $window.height
    end
    return [x,y]
  end
    
	def update
    super
    
    push_game_state(GameOver) if @player.lives == 0
    
    @score.text = "Score: #{@player.score}  Lives: #{@player.lives}"
    
    if $window.ticks % 30 == 0
      x, y = random_entry_point
      Enemy.new(:x => x, :y => y, :level => options[:level], :type => rand(2))
    end
    
    @bullets = game_objects_of_class(Bullet)
    
    PowerUp.all.each do |power_up|
      if power_up.alive? && @player.collides_with?(power_up)
        @player.take(power_up)
        power_up.die!
      end
    end
    
    
    #
    # Loop thru all enemies, aim them at player and do collidestuff
    #
    Enemy.all.select { |enemy| enemy.alive? }.each do |enemy|
      # Aim all enemies at player
      enemy.aim_at(@player.x, @player.y)
      
      # Collide enemies with our bullets, damage enemies and kill bullets
      [enemy].collide_by_radius(@bullets) do |enemy, bullet|
        enemy.damage(bullet.health)
        bullet.die!
        
        #power_up_from(enemy)  if enemy.dying?
        PowerUp.new_from(enemy)  if enemy.dying?
      end

      # Collide all enemies with player, damage player and kill enemy
      [enemy].collide_by_radius([@player]) do |enemy, player|
        player.damage(enemy.health)        
        enemy.die!
      end
      
    end
      
    #
    # Do some garbagecollection every 10 click, remove all dead objects and objcts outside screen.
    #
    #if $window.ticks % 10 == 0
    @game_objects.reject! { |object| (object.respond_to?(:status) && object.dead?) || object.outside_window? }
    #end
    #@game_objects.reject! { |object| object.outside_window? }
	end
	
	def draw
		#Image["background#{options[:level]}.png"].draw(0, 0, 0)
    super
	end
end



		
    #
    #  # Collide all enemies with eachother (they "bump" into eachother and get stuck)
    #  @enemies.collide_by_radius(@enemies) do |enemy, enemy2|
    #    # Ensure that it's 2 different enemies
    #    if enemy.object_id != enemy2.object_id
    #      
    #      # Revert the last X/Y move for the enemy that's farthest from player
    #      # This makes him stop while the closes enemy keeps moving towards player
    #      farthest_enemy = @player.distance_to(enemy) > @player.distance_to(enemy2) ? enemy : enemy2
    #      farthest_enemy.x = farthest_enemy.prev_x
    #      farthest_enemy.y = farthest_enemy.prev_y
    #    end
    #  end
