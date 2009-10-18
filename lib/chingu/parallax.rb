#--
#
# Chingu -- OpenGL accelerated 2D game framework for Ruby
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++

module Chingu
  #
  # Class for simple parallaxscrolling
  #
  # See http://en.wikipedia.org/wiki/Parallax_scrolling for information about parallaxscrolling.
  #
  # Basic usage:
  #   @parallax = Chingu::Parallax.create(:x => 0, :y => 0)
  #   @parallax << Chingu::ParallaxLayer.new(:image => "far_away_mountins.png", :damping => 20, :center => 0)
  #   @parallax << Chingu::ParallaxLayer.new(:image => "trees.png", :damping => 5, :center => 0)
  #
  class Parallax < Chingu::GameObject
    attr_reader :layers

    #
    # Options (in hash-format):
    #
    # repeat: [true|false]  When one layer ends within the screen, repeat/loop it
    #
    def initialize(options = {})
      super(options)
      @repeat = options[:repeat] || true
      @layers = Array.new
    end
    
    #
    # Add one layer, either an ParallaxLayer-object or a Hash of options to create one
    # You can also add new layers with the shortcut "<<":
    #   @parallax << {:image => "landscape.png", :damping => 1}
    #
    def add_layer(arg)
      @layers << (arg.is_a?(ParallaxLayer) ? arg : ParallaxLayer.new(arg))
    end
    alias << add_layer

    
    #
    # Parallax#camera_x= works in inverse to Parallax#x (moving the "camera", not the image)
    #
    def camera_x=(x)
      @x = -x
    end

    #
    # Parallax#camera_y= works in inverse to Parallax#y (moving the "camera", not the image)
    #
    def camera_y=(y)
      @y = -y
    end

    #
    # Get the x-coordinate for the camera (inverse to x)
    #
    def camera_x
      -@x
    end

    #
    # Get the y-coordinate for the camera (inverse to y)
    #
    def camera_y
      -@y
    end
    
    #
    # TODO: make use of $window.milliseconds_since_last_update here!
    #
    def update
      @layers.each do |layer|
        layer.x = @x / layer.damping
        layer.y = @y / layer.damping
        
        # This is the magic that repeats the layer to the left and right
        layer.x -= layer.image.width  while layer.x > 0
      end
    end
    
    #
    # Draw 
    #
    def draw
      @layers.each do |layer|
        layer.draw
        
        save_x = layer.x
        
        ## If layer lands inside our screen, repeat it
        while (layer.x + layer.image.width) < $window.width
          layer.x += layer.image.width
          layer.draw
        end
                
        layer.x = save_x
      end
      self
    end
  end
  
  #
  # ParallaxLayer is mainly used by class Parallax to keep track of the different layers.
  # If you @parallax << { :image => "foo.png" } a ParallaxLayer will be created automaticly from that Hash.
  #
  # If no zorder is provided the ParallaxLayer-class increments an internal zorder number which will
  # put the last layer added on top of the rest.
  #
  class ParallaxLayer < Chingu::GameObject    
    @@zorder_counter = 0
    attr_reader :damping
    
    def initialize(options)
      # No auto update/draw, the parentclass Parallax takes care of that!
      options.merge!(:visible => false, :paused => true)
      
      # If no zorder is given, use a global incrementing counter. First added, furthest behind when drawn.
      options.merge!(:zorder => (@@zorder_counter+=1))  if options[:zorder].nil?
      
      super(options)
      
      @damping = options[:damping] || 10
    end
    
    #
    # Gets pixel from layers image
    # The pixel is from the window point of view, so coordinates are converted:
    #
    #   @parallax.layers.first.get_pixel(10, 10)        # the visible pixel at 10, 10
    #   @parallax.layers.first.image.get_pixel(10, 10)  # gets pixel 10, 10 from layers image no matter where layer is positioned
    #
    def get_pixel(x, y)
      image_x = x - @x
      image_y = y - @y
      
      # On a 100 x 100 image, get_pixel works to 99 x 99
      image_x -= @image.width   while image_x >= @image.width 
      
      @image.get_pixel(image_x, image_y)
    end
    
  end
end