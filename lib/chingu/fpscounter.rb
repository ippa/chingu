module Chingu
  #
  # Calculates a fps and a tick-time for use in update-calls
  # register_tick() must be called every game loop iteration
  #
	class FPSCounter
		attr_reader :fps, :milliseconds_since_last_tick, :ticks
  
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
      # useful in update()-calls
      #
			@milliseconds_since_last_tick = Gosu::milliseconds - @last_value
			@last_value = Gosu::milliseconds
			return @milliseconds_since_last_tick
		end
	end
end
