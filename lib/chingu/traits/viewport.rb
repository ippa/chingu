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
      attr_accessor :viewport
      
      module ClassMethods
        def initialize_trait(options = {})
          trait_options[:viewport] = {:apply => true}.merge(options)
        end
      end
      
      def setup_trait(options)
        @viewport_options = {:debug => false}.merge(options)
        
        @viewport = Chingu::Viewport.new()
        @viewport.x = options[:viewport_x] || 0
        @viewport.y = options[:viewport_y] || 0
        
        super
      end
      
      def inside_viewport?(object)
        puts "Deprecated, use self.viewport.inside?() instead"
        object.x >= @viewport.x && object.x <= (@viewport.x + $window.width) &&
        object.y >= @viewport.y && object.y <= (@viewport.y + $window.height)
      end

      # Returns true object is outside the view port
      def outside_viewport?(object)
        puts "Deprecated, use self.viewport.outside?() instead"
        not inside_viewport?(object)
      end
      
			# Take care of laggy viewport movements
      def update_trait
				@viewport.move_towards_target
				super
      end
      
      #
      # Override game states default draw that draws objects relative to the viewport.
      # It only draws game objects inside the viewport. (GOSU does no such optimizations)
      #
      def draw
        self.game_objects.draw_relative(-@viewport.x, -@viewport.y)
      end      
    end
  end
end