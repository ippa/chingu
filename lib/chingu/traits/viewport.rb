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
  module Traits
    #
    # A chingu trait providing velocity and acceleration logic. 
    # Adds parameters: velocity_x/y, acceleration_x/y and modifies self.x / self.y
    # Also keeps previous_x and previous_y which is the x, y before modification.
    # Can be useful for example collision detection
    #
    module Viewport
      attr_accessor :viewport_x, :viewport_y
      attr_accessor :viewport_x_min, :viewport_y_min
      attr_accessor :viewport_x_max, :viewport_y_max
      
      module ClassMethods
        def initialize_trait(options = {})
          trait_options[:viewport] = {:apply => true}.merge(options)
        end
      end
      
      def setup_trait(options)
        @viewport_options = {:debug => false}.merge(options)
        @viewport_x = options[:viewport_x] || 0
        @viewport_y = options[:viewport_y] || 0

        # In it's most simple explanation, remove @camera_x from every game objects @x when drawing. Same for @y.
        @viewport_x_min = nil
        @viewport_x_max = nil
        @viewport_y_min = nil
        @viewport_y_max = nil
        
        super
      end
      
      def viewport_x=(x)
        @viewport_x = x
        @viewport_x = @viewport_x_min   if @viewport_x_min && @viewport_x < @viewport_x_min
        @viewport_x = @viewport_x_max   if @viewport_x_max && @viewport_x > @viewport_x_max
      end
      
      def viewport_y=(y)
        @viewport_y = y
        @viewport_y = @viewport_y_min   if @viewport_y_min && @viewport_y < @viewport_y_min
        @viewport_y = @viewport_y_max   if @viewport_y_max && @viewport_y > @viewport_y_max
      end
      
      def draw
        @game_objects.draw_relative(-@viewport_x, -@viewport_y)
      end
      
    end
  end
end