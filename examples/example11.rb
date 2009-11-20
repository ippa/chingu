require 'rubygems'
require 'opengl'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# Animation / retrofy example
#
class Game < Chingu::Window
  attr_reader :factor
  
  def initialize
    super    
    @factor = 6
    self.input = { :escape => :exit }          
    self.caption = "Chingu::Animation / retrofy example. Move with arrows!"
    Droid.create(:x => $window.width/2, :y => $window.height/2)
  end
end

class Droid < Chingu::GameObject
  has_traits :timer
  
  def initialize(options = {})
    super
    
    self.input = {  :holding_left => :left,
                    :holding_right => :right,
                    :holding_up => :up,
                    :holding_down => :down }
    
    # Load the full animation from tile-file media/droid.bmp
    @full_animation = Chingu::Animation.new(:file => "droid.bmp", :size => [11,16]).retrofy
    
    # Create new animations from specific frames and stuff them into easy to access hash
    @animations = {}
    @animations[:scan] = @full_animation[0..5]
    @animations[:up] = @full_animation[6..7]
    @animations[:down] = @full_animation[8..9]
    @animations[:left] = @full_animation[10..11]
    @animations[:right] = @full_animation[12..13]
    
    # Start out by animation frames 0-5 (contained by @animations[:scan])
    @animation = @animations[:scan]
    
    self.factor = $window.factor
    @last_x, @last_y = @x, @y
    update
  end
    
  def left
    @x -= 2
    @animation = @animations[:left]
  end

  def right
    @x += 2
    @animation = @animations[:right]
  end

  def up
    @y -= 2
    @animation = @animations[:up]
  end

  def down
    @y += 2
    @animation = @animations[:down]
  end

  # We don't need to call super() in update().
  # By default GameObject#update is empty since it doesn't contain any gamelogic to speak of.
  def update
    
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation.next
    
    #
    # If droid stands still, use the scanning animation
    #
    if @x == @last_x && @y == @last_y
      @animation = @animations[:scan]
    end
    
    @x, @y = @last_x, @last_y if outside_window?  # return to previous coordinates if outside window
    @last_x, @last_y = @x, @y                     # save current coordinates for possible use next time
  end
end

Game.new.show