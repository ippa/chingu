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
    self.input = {  :holding_left => :scroll_left, :holding_right => :scroll_right, :escape => :exit }
          
    self.caption = "Chingu::Parallax example. Scroll with left/right arrows."
    
    @parallax = Chingu::Parallax.create(:x => 0, :y => 0, :center_x => 0, :center_y => 0)
    
    #
    # If no :zorder is given to @parallax.add_background it defaults to first added -> lowest zorder
    # Everywhere the :image argument is used, theese 2 values are the Same:
    # 1) Image["foo.png"]  2) "foo.png"
    #
    # TODO: scrolling to left borks outm, fix. + get rid of center_x / center_y args in a clean way.
    @parallax.add_background(:image => "Parallax-scroll-example-layer-0.png", :damping => 100, :center => 0)
    @parallax.add_background(:image => "Parallax-scroll-example-layer-1.png", :damping => 10, :center => 0)
    @parallax.add_background(:image => "Parallax-scroll-example-layer-2.png", :damping => 5, :center => 0)
    @parallax << {:image => "Parallax-scroll-example-layer-3.png", :damping => 1, :center => 0} # you can also add like this
  end
  
  def scroll_left
    @parallax.x -= 2
  end
  
  def scroll_right
    @parallax.x += 2
  end  
  
end

Game.new.show