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
  module AsyncTasks
    
    #
    # Basic tweening for numerical properties.
    #
    # 	game_object.async.tween 1000, :property => new_value
    #
    class Tween < BasicTask
      
      # TODO Tweening is pretty dumb...make it smarter.
      
      def initialize(duration, properties)
        super()
        @have_initial_values = false
        @age, @life = 0, duration
        @properties = properties
      end
      
      def update(object)
        set_initial_values(object) unless have_initial_values?
        
        @age += $window.milliseconds_since_last_tick
        t = @age.to_f / @life
        t = 1.0 if t > 1
        @properties.each do |name, range|
          object.send "#{name}=", range.interpolate(t)
        end
      end
      
      def finished?
        @age >= @life
      end
      
      private
      
      def set_initial_values(object)
        # TODO find a better and more general way to set up tweening.
        @properties.each do |name, value|
          @properties[name] = object.send(name) .. value
        end
        @have_initial_values = true
      end
      
      def have_initial_values?
        !!@have_initial_values
      end
      
    end
    
  end
end
