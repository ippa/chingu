require 'spec_helper'

module Chingu

  describe Parallax do  
    before :all do
      @game = Chingu::Window.new
      
      # Gosu uses the paths based on where rspec is, not where this file is, so we need to do it manually!
      Gosu::Image::autoload_dirs.unshift File.join(File.dirname(File.expand_path(__FILE__)), 'images')
    end
    
    context "layers" do
      before :all do
        @parallax = Parallax.new
        @parallax << {:image => "rect_20x20.png", :repeat_x => true, :repeat_y => true}
        @parallax.add_layer(:image => "rect_20x20.png", :repeat_x => true, :repeat_y => true)
        @parallax << ParallaxLayer.new(:image => "rect_20x20.png", :repeat_x => true, :repeat_y => true)
      end
      
      it "should have 3 different ways of adding layers" do
        @parallax.layers.count.should == 3
      end
      
      it "should have incrementing zorder" do
        @parallax.layers[0].zorder == 0
        @parallax.layers[1].zorder == 1
        @parallax.layers[2].zorder == 2
      end
    end
    
  end

end
