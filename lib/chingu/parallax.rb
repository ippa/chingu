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
    # repeat_x: [true|false]  repeat layer on X-axis
    # repeat_y: [true|false]  repeat layer on Y-axis
    #
    def initialize(options = {})
      super(options)
      @repeat_x = options[:repeat_x] || true
      @repeat_y = options[:repeat_y] || false
      @cx = 0
      @cy = 0
      
      @layers = Array.new
    end
    
    #
    # Add one layer, either an ParallaxLayer-object or a Hash of options to create one
    # You can also add new layers with the shortcut "<<":
    #   @parallax << {:image => "landscape.png", :damping => 1}
    #
    def add_layer(arg)
      @layers << (arg.is_a?(ParallaxLayer) ? arg : ParallaxLayer.new(arg.merge({:parallax => self})))
    end
    alias << add_layer

    
    #
    # returns true if any part of the parallax-scroller is inside the window
    #
    def inside_window?
      return true if @repeat_x || @repeat_y
      @layers.each { |layer| return true if layer.inside_window? }
      return false
    end

    #
    # Returns true if all parallax-layers are outside the window
    #
    def outside_window?
      not inside_window?
    end
    
    #
    # Parallax#camera_x= works in inverse to Parallax#x (moving the "camera", not the image)
    #
    def camera_x=(x)
      @cx = -x
    end

    #
    # Parallax#camera_y= works in inverse to Parallax#y (moving the "camera", not the image)
    #
    def camera_y=(y)
      @cy = -y
    end

    #
    # Get the x-coordinate for the camera (inverse to x)
    #
    def camera_x
      -@cx
    end

    #
    # Get the y-coordinate for the camera (inverse to y)
    #
    def camera_y
      -@cy
    end
    
    #
    # TODO: make use of $window.milliseconds_since_last_update here!
    #
    def update
      # Viewport data, from GameState parent
      if self.parent.respond_to? :viewport
	      vpX, vpY = self.camera_x, self.camera_y
      else
	      vpX, vpY = 0, 0
      end
  
      @layers.each do |layer|
      	# Get the points which need start to draw
        layer.x = self.x + (vpX - self.camera_x/layer.damping.to_f).round
        layer.y = self.y + (vpY - self.camera_y/layer.damping.to_f).round

        # This is the magic that repeats the layer to the left and right
        layer.x -= layer.image.width  while (layer.repeat_x && layer.x > 0)
       
        # This is the magic that repeats the layer to the left and right
        layer.y -= layer.image.height while (layer.repeat_y && layer.y > 0)
      end
    end
    
    #
    # Draw 
    #
    def draw
#      # Viewport data, from GameState parent
#      if  self.parent.respond_to? :viewport
#      	gaX, gaY, vpW, vpH = self.parent.viewport.game_area
#      else
#      	gaX, gaY, vpW, vpH = 0, 0, $window.width, $window.height
#      end
#      vpX, vpY = @x, @y

      if  self.parent.respond_to? :viewport
        gaX, gaY, vpW, vpH = self.parent.viewport.game_area
      else
        gaX, gaY, vpW, vpH = 0, 0, $window.width, $window.height
      end

      @layers.each do |layer|
      	saveX, saveY = layer.x, layer.y
        # If layer lands inside our window and repeat_x is true (defaults to true), draw it until window ends
        while layer.repeat_x && layer.x < vpW
          while layer.repeat_y && layer.y < vpH
            layer.draw
            layer.y += layer.image.height
          end
          layer.y = saveY

          layer.draw
          layer.x += layer.image.width
        end
        
        # Special loop for when repeat_y is true but not repeat_x
        if layer.repeat_y && !layer.repeat_x
          while layer.repeat_y && layer.y < vpH
            layer.draw
            layer.y += layer.image.height
          end
        end
        layer.x = saveX
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
    attr_reader :damping
    attr_accessor :repeat_x, :repeat_y
    
    def initialize(options)      
      @parallax = options[:parallax]      
      # No auto update/draw, the parentclass Parallax takes care of that!
      options.merge!(:visible => false, :paused => true)
    
      options = {:rotation_center => @parallax.options[:rotation_center]}.merge(options)  if @parallax
      
      #
      # Default arguments for repeat_x and repeat_y
      # If no zorder is given, use a global incrementing counter. 
      # First added, furthest behind when drawn.
      #
      options = {
          :repeat_x => true, 
          :repeat_y => false, 
          :zorder   => @parallax ? (@parallax.zorder + @parallax.layers.count) : 100
      }.merge(options)
            
      @repeat_x = options[:repeat_x]
      @repeat_y = options[:repeat_y]
            
      super(options)
      
      @damping = options[:damping] || 1
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