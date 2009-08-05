module Chingu
	class MovingActor < Actor
		attr_accessor :velocity, :directions, :speed
		attr_reader :status, :keymap
		
		def initialize(options)
			super
			@speed = options[:speed] || 1
			@velocity = Velocity.new(0,0,0)
			@status = :default
			@directions = Hash.new
		end
		
		def moving?
			@velocity.x != 0 || @velocity.y != 0
		end
		def still?
			@velocity.x == 0 && @velocity.y == 0 && @status == :default
		end
		def jumping?
			@status == :jumping
		end
		
		def move
			@x += @velocity.x
			@y += @velocity.y
			@z += @velocity.z
			@z = 0	if @z < 0
		end
		
		def right
			@velocity.x = @speed
			@directions[:right] = true and @directions[:left] = false
		end
		def left
			@velocity.x = -@speed
			@directions[:left] = true	and @directions[:right] = false
		end
		def up
			@velocity.y = -@speed
			@directions[:up] = true
		end
		def down
			@velocity.y = @speed
			@directions[:down] = true
		end
		def land
			@status = :default
		end
		def stop
			@velocity.x = @velocity.y = 0
			## @status = :default	unless jumping?
		end
		
		def update
			move
		end
	end
end