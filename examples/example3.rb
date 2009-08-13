require 'rubygems'
require '../lib/chingu.rb'
include Gosu

#
# Parallax-example
# Images from http://en.wikipedia.org/wiki/Parallax_scrolling
#
class Game < Chingu::Window
  def initialize
    super    
    self.input = {:holding_left => :scroll_left, :holding_right => :scroll_right, :escape => :close}
    
    @parallax = Chingu::Parallax.new(:x => 0, :y => 0, :center_x => 0, :center_y => 0)
    
    #
    # If no :zorder is given to @parallax.add_background it defaults to first added -> lowest zorder
    # Everywhere the :image argument is used, theese 2 values are the Same:
    # 1) Image["foo.png"]  2) "foo.png"
    #
    # TODO: scrolling to left borks outm, fix. + get rid of center_x / center_y args in a clean way.
    @parallax.add_background(:image => "Parallax-scroll-example-layer-0.png", :damping => 100, :center_x => 0, :center_y => 0)
    @parallax.add_background(:image => "Parallax-scroll-example-layer-1.png", :damping => 10, :center_x => 0, :center_y => 0)
    @parallax.add_background(:image => "Parallax-scroll-example-layer-2.png", :damping => 5, :center_x => 0, :center_y => 0)
    @parallax.add_background(:image => "Parallax-scroll-example-layer-3.png", :damping => 1, :center_x => 0, :center_y => 0)
  end
  
  def scroll_left
    @parallax.x -= 2
  end
  
  def scroll_right
    @parallax.x += 2
  end  
end

Game.new.show