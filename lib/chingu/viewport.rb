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
  # A basic viewport class
  #
  # TODO:
  # Implement use of viewports angle, center_x, center_y, factor_x, factor_y
  #
  class Viewport
    attr_accessor :x, :y#, :x_min, :x_max, :y_min, :y_max
		attr_accessor :x_target, :y_target, :x_lag, :y_lag, :game_area
    
    def initialize(options = {})
      @x = options[:x] || 0
      @y = options[:y] || 0
			@x_target = options[:x_target]
			@y_target = options[:y_target]
			@x_lag = options[:x_lag] || 0
			@y_lag = options[:y_lag] || 0
      @game_area = Chingu::Rect.new(options[:game_area]||[@x, @y, $window.width, $window.height])      
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
    
    def game_area=(rect)
      @game_area = Rect.new(rect)
    end
    
    #
    # Returns true if object is inside view port, false if outside
    # TODO: add view port height and width! (and use clip_to when painting?)
    #
    # This is a very flawed implementation, it Should take inte account objects 
    # height,width,factor_x,factor_y,center_x,center_y as well...
    #
    def inside?(object)
      object.x >= @x && object.x <= (@x + $window.width) &&
      object.y >= @y && object.y <= (@y + $window.height)
    end

    # Returns true object is outside the view port
    def outside?(object)
      not inside_viewport?(object)
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
    
  end
end