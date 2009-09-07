#
# Our basic class that every ingame object inherits from
#
class MyGameObject < Chingu::GameObject
  attr_accessor :lives, :health, :speed_x, :speed_y
  attr_reader :status, :radius, :punch
 
  def initialize(options)
    super
    @status = :default
  end
  def damage(punch)
    @health = 0 if @health.nil? ## ugly fix for something :/
      
    @health -= punch
    if @health <= 0
      @health = 0
      die!
    end
    self
  end
  
  def collides_with?(object)
    distance(self.x, self.y, object.x, object.y) < self.radius
  end
		
  def die!
    @lives -= 1 if defined?(@lives)
    @status = :dead
    self
  end

  def alive?
    @status == :default
  end

  def dead?
    @status == :dead
  end
  
  def dying?
    @status == :dying
  end
  
end

