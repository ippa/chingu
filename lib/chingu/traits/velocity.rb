#--
#
# Chingu -- Game framework built on top of the opengl accelerated gamelib Gosu
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
    #
    module Velocity
      attr_accessor :velocity_x, :velocity_y, :acceleration_x, :acceleration_y, :max_velocity
      
      #def self.initialize_trait(options)
      #  @velocity_options = {:debug => false}.merge(options)
      #  puts "Velocity#initialize"    if @velocity_options[:debug]
      #  super
      #end
            
      def setup_trait(options)
        @velocity_options = {:debug => false}.merge(options)        
        puts "Velocity#setup"   if @velocity_options[:debug]
        
        @velocity_x = options[:velocity_x] || 0
        @velocity_y = options[:velocity_y] || 0
        @acceleration_x = options[:acceleration_x] || 0
        @acceleration_y = options[:acceleration_y] || 0
        @max_velocity = options[:max_velocity] || 1000
        super
      end
      
      #
      # Modifies X & Y of parent
      #
      def update
        puts "Velocity#update"    if @velocity_options[:debug]
        
        @velocity_y += @acceleration_y		if	(@velocity_y + @acceleration_y).abs < @max_velocity
        @velocity_x += @acceleration_x		if	(@velocity_x + @acceleration_x).abs < @max_velocity
        @y += @velocity_y
        @x += @velocity_x
        super
      end
      
      def stop
        @acceleration_y = @acceleration_x = @velocity_y = @acceleration_y = 0
      end      
    end
  end
end