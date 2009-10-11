require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu

#
# Parallax-example
# Images from http://en.wikipedia.org/wiki/Parallax_scrolling
#
class Game < Chingu::Window
  def initialize
    super(600,200)
    self.input = {  :holding_left => :camera_left, 
                    :holding_right => :camera_right, 
                    :holding_up => :camera_up,
                    :holding_down => :camera_down,
                    :escape => :exit }
          
    self.caption = "Chingu::Parallax example. Scroll with left/right arrows."
    
    @parallax = Chingu::Parallax.create(:x => 0, :y => 0, :center_x => 0, :center_y => 0)
    
    #
    # If no :zorder is given to @parallax.add_layer it defaults to first added -> lowest zorder
    # Everywhere the :image argument is used, theese 2 values are the Same:
    # 1) Image["foo.png"]  2) "foo.png"
    #
    # Notice we add layers to the parallax scroller in 3 different ways. 
    # They all end up as ParallaxLayer-instances internally
    #
    @parallax.add_layer(:image => "Parallax-scroll-example-layer-0.png", :damping => 100, :center => 0)
    @parallax.add_layer(:image => "Parallax-scroll-example-layer-1.png", :damping => 10, :center => 0)
    @parallax << Chingu::ParallaxLayer.new(:image => "Parallax-scroll-example-layer-2.png", :damping => 5, :center => 0)
    @parallax << {:image => "Parallax-scroll-example-layer-3.png", :damping => 1, :center => 0} # you can also add like this
  end
  
  def camera_left
    # This is essentially the same as @parallax.x += 2
    @parallax.camera_x -= 2
  end
  
  def camera_right
    # This is essentially the same as @parallax.x -= 2
    @parallax.camera_x += 2
  end  

  def camera_up
    # This is essentially the same as @parallax.y += 2
    @parallax.camera_y -= 2
  end

  def camera_down
    # This is essentially the same as @parallax.y -= 2
    @parallax.camera_y += 2
  end

end

Game.new.show