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
  # A basic viewport class. Coordinates X and Y are relative to game
  # area that can be specified by any arguments acceptable by
  # Chingu::Rect#new method. By default, the game_area is the same
  # as window and thus the vieport has no effect.
  #
  #
  # TODO:
  # Implement use of viewports angle, center_x, center_y, factor_x, factor_y
  #
  class Viewport
    attr_accessor :x, :y, :x_target, :y_target, :x_lag, :y_lag, :game_area
    
    def initialize(options = {})
      @x = options[:x] || 0
      @y = options[:y] || 0 
      @x_target = options[:x_target] || @x
      @y_target = options[:y_target] || @y
      @x_lag = options[:x_lag] || 0
      @y_lag = options[:y_lag] || 0
      @game_area = Chingu::Rect.new(options[:game_area] || [@x, @y, $window.width, $window.height])       
    end
    
    #
    # Set x_lag and y_lag to value 'lag'
    #
    def lag=(lag)
      @x_lag = @y_lag = lag
    end

    #
    # Center the viewport around the given object (it must respont to x/y)
    # Center will fail if object is in the corners of the game area
    #
    def center_around(object)
      self.x = object.x - $window.width / 2
      self.y = object.y - $window.height / 2
    end
    
    #
    # Set a Rect that represents the borders of the game world.
    # The viewport can only move within this Rect.
    #
    def game_area=(rect)
      @game_area = Rect.new(rect)
    end
    
    #
    # Set a game world by giving it a game object
    # The game objects image will be the rectangle the viewport can move within.
    #
    def game_area_object=(game_object)
      image = (game_object.is_a? Gosu::Image) ? game_object : game_object.image
      @game_area = Rect.new(0,0,
                            (image.width*$window.factor) - $window.width, 
                            (image.height*$window.factor) - $window.height
                            )
    end
    
    #
    # Returns true if object is inside view port, false if outside
    # TODO: add view port height and width! (and use clip_to when painting?)
    #
    # This is a very flawed implementation, it Should take inte account objects 
    # height,width,factor_x,factor_y,center_x,center_y as well...
    #
    def inside?(object, y = nil)
      x, y = y ? [object,y] : [object.x, object.y]
      x >= @x && x <= (@x + $window.width) &&
      y >= @y && y <= (@y + $window.height)
    end

    # Returns true object is outside the view port
    def outside?(object, y)
      not inside?(object, y)
    end
      
    #
    # Returns true object is inside the game area
    # The "game area" is the full map/world/area from which the viewport shows a slice
    # The viewport can't show anything outside the game area
    #
    def inside_game_area?(object)        
      object.x >= @game_area.x && object.x <= (@game_area.width + $window.width) &&
      object.y >= @game_area.x && object.y <= (@game_area.height + $window.height)
    end
      
    # Returns true object is outside the game area
    def outside_game_area?(object)
      not inside_game_area?(object)
    end

    #
    # Modify viewports x and y from target_x / target_y and x_lag / y_lag 
    # Use this to have the viewport "slide" after the player
    #
    def move_towards_target			
      if @x_target && @x != @x_target
        x_step = @x_target - @x
        self.x = @x + x_step * (1.0 - @x_lag)
      end
      
      if @y_target && @y != @y_target
        y_step = @y_target - @y
        self.y = @y + y_step * (1.0 - @y_lag)
      end
    end
    
    #
    # Viewports X setter with boundschecking
    #
    def x=(x)
      @x = x
      if @game_area
        @x = @game_area.x       if @x < @game_area.x
        @x = @game_area.width   if @x > @game_area.width
      end 
    end

		#
		# Viewports Y setter with boundschecking
		#
    def y=(y)
      @y = y
      if @game_area
        @y = @game_area.y       if @y < @game_area.y
        @y = @game_area.height  if @y > @game_area.height
      end
    end
    
    def apply(&block)
      $window.translate(-@x, -@y, &block)
    end    
    
  end
end
