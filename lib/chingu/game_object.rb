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
    attr_reader :factor, :center#, :rotation_center
    
    include Chingu::Helpers::InputClient        # Adds input and input=
    include Chingu::Helpers::RotationCenter     # Adds easy and verbose modification of @center_x and @center_y
        
    def initialize(options = {})
      super

      # All encapsulated draw_rot arguments can be set with hash-options at creation time
      if options[:image].is_a?(Gosu::Image)
        @image = options[:image]
      elsif options[:image].is_a? String
        @image = Gosu::Image[options[:image]]
      end
      
      @x = options[:x] || 0
      @y = options[:y] || 0
      @angle = options[:angle] || 0
      
      self.factor = options[:factor] || options[:scale] || 1.0
      @factor_x = options[:factor_x] if options[:factor_x]
      @factor_y = options[:factor_y] if options[:factor_y]
      
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
      

    # Returns true if object is inside the game window, false if outside
    def inside_window?(x = @x, y = @y)
      x >= 0 && x <= $window.width && y >= 0 && y <= $window.height
    end

    # Returns true object is outside the game window 
    def outside_window?(x = @x, y = @y)
      not inside_window?(x,y)
    end
    
    # Calculates the distance from self to a given objevt
    def distance_to(object)
      distance(self.x, self.y, object.x, object.y)
    end
    
    #
    # Our encapsulation of GOSU's image.draw_rot, uses the objects variables to draw it on screen if @visible is true
    #
    def draw
      @image.draw_rot(@x, @y, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode) if @visible
    end
    
    #
    # Works as #draw() but takes offsets for all draw_rot()-arguments. Used among others by by viewport-trait
    #
    def draw_relative(x=0, y=0, zorder=0, angle=0, center_x=0, center_y=0, factor_x=0, factor_y=0)
      @image.draw_rot(@x+x, @y+y, @zorder+zorder, @angle+angle, @center_x+center_x, @center_y+center_y, @factor_x+factor_x, @factor_y+factor_y, @color, @mode) if @visible
    end
    
  end  
end