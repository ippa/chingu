module Chingu
  #
  # The Animation-class helps you load and manage a tileanimation.
  # A Tileanimation is a file where all the frames are put after eachother.
  #
  # An easy to use program to create tileanimations is http://tilestudio.sourceforge.net/
  #
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
      options = {:loop => true, :bounce => false, :width => 32, :height => 32, :index => 0, :delay => 100}.merge(options)
      
      @loop = options[:loop]
      @bounce = options[:bounce]
      @file = options[:file]
      @height = options[:height]
      @width = options[:width]
      @index = options[:index]
      @delay = options[:delay]
      @dt = 0
      
      @frame_actions = []
      @frames = Gosu::Image.load_tiles($window, @file, @width, @height, true)
      @step = 1
    end
    
    #
    # Fetch a certain frame (a Gosu#Image), starts at 0.
    #
    def [](index)
      @frames[index]
    end
		
    #
    # Get the current frame (a Gosu#Image)
    #
    def image
      @frames[@index]
    end
		
    #
    # Resets the animation, re-starts it at frame 0
    #
    def reset!
      @index = 0
    end
		
    #
    # Returns a new animation with the frames from the original animation.
    # Specify which frames you want with "range", for example "0..3" for the 4 first frames.
    #
    def new_from_frames(range)
      new_animation = self.dup
      new_animation.frames = []
      range.each do |nr|
        new_animation.frames << self.frames[nr]
      end
      return new_animation
    end
    
    #
    # Propelles the animation forward. Usually called in #update within the class which holds the animation.
    # #next! will look at bounce and loop flags to always return a correct frame (a Gosu#Image)
    #
    def next!
      if (@dt += $window.milliseconds_since_last_tick) > @delay
        @dt = 0
        @previous_index = @index
        @index += @step
        
        # Has the animation hit end or beginning... time for bounce or loop?
        if (@index >= @frames.size || @index < 0)
          if @bounce
            @step *= -1   # invert number
            @index += @step
          elsif @loop
            @index = 0	
          else
            @index = @previous_index # no bounce or loop, use previous frame
          end
        end
        @frame_actions[@index].call	if	@frame_actions[@index]
      end
      @frames[@index]
    end
		
    #
    # Execute a certain block of code when a certain frame in the animation is active.
    # This could be used for pixel perfect animation/movement.
    #
    def on_frame(frames, &block)
      if frames.kind_of? Array
        frames.each { |frame| @frame_actions[frame] = block }
      else
        @frame_actions[frames] = block
      end
    end		
  end
end