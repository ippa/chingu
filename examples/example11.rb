require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu

#
# Parallax-example
# Images from http://en.wikipedia.org/wiki/Parallax_scrolling
#
class Game < Chingu::Window
  def initialize
    super    
    self.input = {  :holding_left => :scroll_left,
                    :holding_right => :scroll_right,
                    :holding_up => :scroll_up,
                    :holding_down => :scroll_down, 
                    :escape => :exit }
          
    self.caption = "Chingu::Parallax example. Scroll with left/right arrows."
    
    @parallax = Chingu::Parallax.create(:x => 0, :y => 0, :center_x => 0, :center_y => 0)
    
    #
    # If no :zorder is given to @parallax.add_background it defaults to first added -> lowest zorder
    # Everywhere the :image argument is used, theese 2 values are the Same:
    # 1) Image["foo.png"]  2) "foo.png"
    #
    # TODO: scrolling to left borks outm, fix. + get rid of center_x / center_y args in a clean way.
    @parallax << {:image => "paralaxx2", :damping => 100, :center => 0)
    @parallax << {:image => "parallax-scroll-example-layer-1.png", :damping => 10, :center => 0)
    @parallax << {:image => "paralaxx2.png", :damping => 5, :center => 0)
  end
  
  def scroll_left
    @parallax.x -= 2
  end
  
  def scroll_right
    @parallax.x += 2
  end  
  
  def scroll_up
    @parallax.y -= 2
  end
  
  def scroll_down
    @parallax.y += 2
  end  
  
end

Game.new.show