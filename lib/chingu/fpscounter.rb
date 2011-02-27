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
  # Calculates a fps and a tick-time for use in update-calls
  # register_tick() must be called every game loop iteration
  #
	class FPSCounter
    attr_reader :milliseconds_since_last_tick
    alias :dt :milliseconds_since_last_tick
    
    #
    # Frames per second, access with $window.fps or $window.framerate
    #
    attr_reader :fps
    alias :framerate :fps
    
    #
    # Total amount of game iterations (ticks)
    #
    attr_reader :ticks
  
		def initialize
			@current_second = Gosu::milliseconds / 1000
			@accum_fps = 0
			@fps = 0
      @ticks = 0
      
      @milliseconds_since_last_tick = 0
			@last_value = Gosu::milliseconds
		end
  
    #
    # This should be called once every game-iteration, preferable in update()
    #
		def register_tick
			@accum_fps += 1
      @ticks += 1
			current_second = Gosu::milliseconds / 1000
			if current_second != @current_second
				@current_second = current_second
				@fps = @accum_fps
				@accum_fps = 0
			end

      #
      # Calculate how many milliseconds passed since last game loop iteration.
      #
			@milliseconds_since_last_tick = Gosu::milliseconds - @last_value
			@last_value = Gosu::milliseconds
			return @milliseconds_since_last_tick
		end
	end
end
