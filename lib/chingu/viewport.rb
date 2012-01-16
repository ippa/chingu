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
  # Implement use of viewports angle, center_x, center_y
  #
  class Viewport
    attr_accessor :x, :y, :x_target, :y_target, :x_lag, :y_lag, :factor_x, :factor_y, :game_area
    
    def initialize(options = {})
      @x = options[:x] || 0
      @y = options[:y] || 0 
      @x_target = options[:x_target] || @x
      @y_target = options[:y_target] || @y
      @x_lag = options[:x_lag] || 0
      @y_lag = options[:y_lag] || 0
      @factor_x = options[:factor_x] || 1
      @factor_y = options[:factor_y] || 1
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
    # TODO: Add support for x,y here!
    #
    def center_around(object)
      self.x = object.x * @factor_x - $window.width / 2
      self.y = object.y * @factor_y - $window.height / 2
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
      @game_area = Rect.new(0, 0, game_object.width, game_object.height)
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
    def outside?(object, y = nil)
      not inside?(object, y)
    end
      
    #
    # Returns true object is inside the game area
    # The "game area" is the full map/world/area from which the viewport shows a slice
    # The viewport can't show anything outside the game area
    #
    def inside_game_area?(object)        
      object.x >= @game_area.x && object.x <= @game_area.width &&
      object.y >= @game_area.x && object.y <= @game_area.height
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
        x_step = @x_target * @factor_x - @x
        self.x = @x + x_step * (1.0 - @x_lag)
      end

      if @y_target && @y != @y_target
        y_step = @y_target * @factor_y - @y
        self.y = @y + y_step * (1.0 - @y_lag)
      end
    end
    
    #
    # Viewports X setter with boundschecking
    #
    def x=(x)
      @x = x
      if @game_area
        @x = @game_area.x * @factor_x         if @x < @game_area.x * @factor_x
        @x = @game_area.width * @factor_x - $window.width   if @x > @game_area.width * @factor_x - $window.width
      end
    end

    #
    # Viewports Y setter with boundschecking
    #
    def y=(y)
      @y = y
      if @game_area
        @y = @game_area.y * @factor_y           if @y < @game_area.y * @factor_y
        @y = @game_area.height * @factor_y - $window.height   if @y > @game_area.height * @factor_y - $window.height
      end
    end
    
    #
    # Apply the X/Y viewport-translation, used by trait "viewport"
    #
    def apply(&block)
      $window.translate(-@x.to_i, -@y.to_i) do
        $window.scale(@factor_x, @factor_y, 0, 0, &block)
      end
    end

    def to_s
      a = @game_area
      %/
Vieport
 Position: #{@x}, #{@y}
 Game area: #{a.x},#{a.y},#{a.width},#{a.height}"        
 Target: #{@target_x}, #{@target_y}
      /
    end
    
    
  end
end
