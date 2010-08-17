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

require_rel 'helpers/*'
module Chingu
  #
  # GameObject inherits from BasicGameObject to get traits and some class-methods like .all and .destroy
  #
  # On top of that, it encapsulates GOSUs Image#draw_rot and all its parameters.
  #
  # In Chingu GameObject is a visual object, something to put on screen, centers around the .image-parameter.
  #
  # If you wan't a invisible object but with traits, use BasicGameObject.
  #
  class GameObject < Chingu::BasicGameObject
    attr_accessor :image, :x, :y, :angle, :center_x, :center_y, :factor_x, :factor_y, :color, :mode, :zorder
    attr_reader :factor, :center, :height, :width
    
    include Chingu::Helpers::InputClient        # Adds input and input=
    include Chingu::Helpers::RotationCenter     # Adds easy and verbose modification of @center_x and @center_y
        
    def initialize(options = {})
      super
      
      #
      # All encapsulated Gosu::Image.draw_rot arguments can be set with hash-options at creation time
      #
      if options[:image].is_a?(Gosu::Image)
        @image = options[:image]
      elsif options[:image].is_a? String
        begin
          # 1) Try loading the image the normal way
          @image = Gosu::Image.new($window, options[:image])
        rescue
          # 2) Try looking up the picture using Chingus Image-cache
          @image = Gosu::Image[options[:image]]
        end
      end
      
      @x = options[:x] || 0
      @y = options[:y] || 0
      @angle = options[:angle] || 0
      
      self.factor = options[:factor] || options[:scale] || $window.factor || 1.0
      @factor_x = options[:factor_x].to_f if options[:factor_x]
      @factor_y = options[:factor_y].to_f if options[:factor_y]
      
      self.center = options[:center] || 0.5
      
      @rotation_center = options[:rotation_center]
      self.rotation_center(options[:rotation_center]) if options[:rotation_center]
      
      @center_x = options[:center_x] if options[:center_x]
      @center_y = options[:center_y] if options[:center_y]
      
      if options[:color].is_a?(Gosu::Color)
        @color = options[:color]
      else
        @color = Gosu::Color.new(options[:color] || 0xFFFFFFFF)
      end
      
      self.alpha = options[:alpha]  if options[:alpha]
      
      @mode = options[:mode] || :default # :additive is also available.
      @zorder = options[:zorder] || 100
      
      if @image
        self.width = options[:width]   if options[:width]
        self.height = options[:height] if options[:height]
      end

      ### super ## This crashes
      # Call setup, this class holds an empty setup() to be overriden
      # setup() will be an easier method to override for init-stuff since you don't need to do super etc..
      setup
      
    end
   
    #
    # Get all settings from a game object in one array.
    # Complemented by the GameObject#attributes= setter.
    # Makes it easy to clone a objects x,y,angle etc.
    #
    def attributes
      [@x, @y, @angle, @center_x, @center_y, @factor_x, @factor_y, @color.dup, @mode, @zorder]
    end

    #
    # Set all attributes on 1 line
    # Mainly used in combination with game_object1.attributes = game_object2.attributes
    #
    def attributes=(attributes)
      self.x, self.y, self.angle, self.center_x, self.center_y, self.factor_x, self.factor_y, self.color, self.mode, self.zorder = *attributes
    end

    #
    # Set an effective width for the object on screen.
    # Chingu does this by setting factor_x depending on imge.width and width given.
    # Usually better to have a large image and make it smaller then the other way around.
    #
    def width=(width)
      @factor_x = width.to_f / @image.width.to_f
    end
    
    # Get effective on width by calculating it from image-width and factor
    def width
      (@image.width * @factor_x).abs
    end

    #
    # Set an effective height for the object on screen.
    # Chingu does this by setting factor_x depending on imge.width and width given.
    # Usually better to have a large image and make it smaller then the other way around.
    #
    def height=(height)
      @factor_y = height.to_f / @image.height.to_f
    end
    
    # Get effective on heightby calculating it from image-width and factor
    def height
      (@image.height.to_f * @factor_y).abs
    end

    # Set width and height in one swoop
    def size=(size)
      self.width, self.height = *size
    end
    
    # Get objects width and height in an array
    def size
      [self.width, self.height]
    end
      

    # Quick way of setting both factor_x and factor_y
    def factor=(factor)
      @factor = factor
      @factor_x = @factor_y = factor
    end
    alias scale= factor=
    alias scale factor
          
    # Quick way of setting both center_x and center_y
    def center=(center)
      @center = center
      @center_x = @center_y = center
    end
    
    # Get objects alpha-value (internally stored in @color.alpha)
    def alpha
      @color.alpha
    end
    
    # Set objects alpha-value (internally stored in @color.alpha)
    # If out of range, set to closest working value. this makes fading simpler.
    def alpha=(value)
      value = 0   if value < 0
      value = 255 if value > 255
      @color.alpha = value
    end

    #
    # Sets angle, normalize it to between 0..360
    #
    def angle=(value)
      if value < 0
        value = 360+value
      elsif value > 360
        value = value-360
      end
      @angle = value
    end

    #
    # Disable automatic calling of draw and draw_trait each game loop
    #
    def hide!
      @visible = false
    end
    
    #
    # Enable automatic calling of draw and draw_trait each game loop
    #
    def show!
      @visible = true
    end
    
    #
    # Returns true if visible (not hidden)
    #
    def visible?
      @visible == true
    end    


    # Returns true if object is inside the game window, false if outside
    def inside_window?(x = @x, y = @y)
      x >= 0 && x <= $window.width && y >= 0 && y <= $window.height
    end

    # Returns true object is outside the game window 
    def outside_window?(x = @x, y = @y)
      not inside_window?(x,y)
    end
    
    # Calculates the distance from self to a given object
    def distance_to(object)
      distance(self.x, self.y, object.x, object.y)
    end

    #
    # Returns a filename-friendly string from the current class-name
    #
    # "FireBall" -> "fire_ball"
    #
    def filename
      Chingu::Inflector.underscore(self.class.to_s)
    end

    #
    # Our encapsulation of GOSU's image.draw_rot, uses the objects variables to draw it on screen if @visible is true
    #
    def draw
      @image.draw_rot(@x, @y, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode) if @visible
    end
    
    #
    # Works as #draw() but takes offsets for all draw_rot()-arguments. Used among others by the viewport-trait.
    #
    def draw_relative(x=0, y=0, zorder=0, angle=0, center_x=0, center_y=0, factor_x=0, factor_y=0)
      @image.draw_rot(@x+x, @y+y, @zorder+zorder, @angle+angle, @center_x+center_x, @center_y+center_y, @factor_x+factor_x, @factor_y+factor_y, @color, @mode) if @visible
    end

    #
    # Works as #draw() but takes x/y arguments. Used among others by the edit-game state.
    #
    def draw_at(x, y)
      @image.draw_rot(x, y, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode) if @visible
    end
  end  
end