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
    module Velocity
      attr_accessor :velocity_x, :velocity_y, :acceleration_x, :acceleration_y, :max_velocity
      attr_reader :previous_x, :previous_y
      
      module ClassMethods
        def initialize_trait(options = {})
          trait_options[:velocity] = {:apply => true}.merge(options)
        end
      end
      
      def setup_trait(options)
        @velocity_options = {:debug => false}.merge(options)
        
        @velocity_x = options[:velocity_x] || 0
        @velocity_y = options[:velocity_y] || 0
				self.velocity = options[:velocity] if options[:velocity]
				
        @acceleration_x = options[:acceleration_x] || 0
        @acceleration_y = options[:acceleration_y] || 0
				self.acceleration = options[:acceleration] if options[:acceleration]
				
        @max_velocity = options[:max_velocity] || 1000
        super
      end
      
			#
			# Sets X and Y velocity with one single call. Takes an Array-argument with 2 values.
			#
			def velocity=(velocity)
				@velocity_x, @velocity_y = velocity
			end
			
			def velocity; [@velocity_x, @velocity_y]; end

			#
			# Sets X and Y acceleration with one single call. Takes an Array-argument with 2 values.
			#
			def acceleration=(acceleration)
				@acceleration_x, @acceleration_y = acceleration
			end
	
			def acceleration; [@acceleration_x, @acceleration_y]; end

      #
      # Modifies X & Y of parent
      #
      def update_trait
        @velocity_y += @acceleration_y		if	(@velocity_y + @acceleration_y).abs < @max_velocity
        @velocity_x += @acceleration_x		if	(@velocity_x + @acceleration_x).abs < @max_velocity
        
        @previous_y = @y
        @previous_x = @x
        
        #
        # if option :apply is false, just calculate velocities, don't apply them to x/y
        #
        unless trait_options[:velocity][:apply] == false
          self.y += @velocity_y
          self.x += @velocity_x
        end
        
        super
      end
      
      def stop
        # @acceleration_y = @acceleration_x = 0
        @velocity_x = 0
        @velocity_y = 0
      end      
    end
  end
end