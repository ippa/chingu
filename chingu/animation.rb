module Chingu
	class Animation
		attr_accessor :frames
    
    #
    # Create a new Animation. 
    #
    #   - loop: [true|false]. After the last frame is used, start from the beginning.
    #   - bounce: [true|false]. After the last frame is used, play it backwards untill the first frame is used again, then start playing forwards again.
    #   - file:   Tile-file to cut up animation frames from.
    #   - width:  width of each frame in the tileanimation
    #   - height:  width of each frame in the tileanimation
    #
    #
		def initialize(options)
			@loop = options[:loop] || true
			@bounce = options[:bounce] || false
			@file = options[:file]
			@height = options[:height] || 32
			@width = options[:width] || 32
			@index = options[:index] || 0
			@delay = options[:delay] || 100
			@ticks = 0
			
			@frame_actions = []
			@frames = Gosu::Image.load_tiles($window, @file, @width, @height, true)
			@step = 1
		end
		
		def [](index)
			@frames[index]
		end
		
		def image
			@frames[@index]
		end
		
		def reset!
			@index = 0
		end
		
		def new_from_frames(range)
			new_animation = self.dup
			new_animation.frames = []
			range.each do |nr|
				new_animation.frames << self.frames[nr]
			end
			return new_animation
		end
		
		def next!
			if (@ticks += $window.tick) > @delay
				@ticks = 0
				@index += @step
				
				# Time to loop or bounce? Hit end or beginning..
				if (@index >= @frames.size || @index < 0)
					if @bounce
						if @step == 1
							@step = -1
						else
							@step = 1
						end
						@index += @step
					elsif @loop
						@index = 0	
					end
				end
				
				@frame_actions[@index].call	if	@frame_actions[@index]
			end
			@frames[@index]
		end
		
		def on_frame(frames, &block)
			if frames.kind_of? Array
				frames.each { |frame| @frame_actions[frame] = block }
			else
				@frame_actions[frames] = block
			end
		end		
	end
end