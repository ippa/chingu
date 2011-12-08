module Chingu
  #
  # The Animation-class helps you load and manage a tileanimation.
  # A Tileanimation is a file where all the frames are put after eachother.
  #
  # An easy to use program to create tileanimations is http://tilestudio.sourceforge.net/ or http://www.humanbalance.net/gale/us/
  #
  # TODO: 
  # Support frames in invidual image-files?
  # Is autodetection of width / height possible? 
  #
  class Animation
    attr_accessor :frames, :delay, :step, :loop, :bounce, :step, :index
    
    #
    # Create a new Animation. 
    # Must use :file OR :frames OR :image to create it.
    #
    #   - loop: [true|false]. After the last frame is used, start from the beginning.
    #   - bounce: [true|false]. After the last frame is used, play it backwards untill the first frame is used again, then start playing forwards again.
    #   - file:   Tile-file to cut up animation frames from. Could be a full path or just a name -- then it will look for media_path(file)
    #   - frames: Creates the animation from existing images which are the same size (Array<Gosu::Image>)
    #   - image: Image containing a strip of frames for the animation (Gosu::Image)
    #   - width:  width of each frame in the tileanimation
    #   - height:  width of each frame in the tileanimation
    #   - size: [width, height]-Array or just one fixnum which will spez both height and width
    #   - delay: milliseconds between each frame
    #   - step: [steps] move animation forward [steps] frames each time we call #next
    #
    def initialize(options)
      options = {:step => 1, :loop => true, :bounce => false, :index => 0, :delay => 100}.merge!(options)

      @loop = options[:loop]
      @bounce = options[:bounce]
      file = options[:file]
      image = options[:image]
      @frames = options[:frames]
      @index = options[:index]
      @delay = options[:delay]
      @step = options[:step] || 1
      @dt = 0

      @sub_animations = {}
      @frame_actions = []
      
      raise ArgumentError, "Must provide one of :frames, :image OR :file parameter" unless [@frames, file, image].compact.size == 1

      if @frames        
        raise ArgumentError, "Must provide at least one frame image with :frames" if @frames.empty?
        raise ArgumentError, ":frames must consist of images only" unless @frames.all? {|i| i.is_a? Gosu::Image }
        
        @width, @height = @frames[0].width, @frames[0].height
        
        raise ArgumentError, ":frames must be of identical size" unless @frames[1..-1].all? {|i| i.width == @width and i.height == @height }
        
      else    
        if file and not File.exists?(file)
          Gosu::Image.autoload_dirs.each do |autoload_dir|
            full_path = File.join(autoload_dir, file)
            if File.exists?(full_path)
              file = full_path
              break
            end
          end      
        end

        #
        # Various ways of determening the framesize
        #
        if options[:height] && options[:width]
          @height = options[:height]
          @width = options[:width]
        elsif options[:size] && options[:size].is_a?(Array)
          @width = options[:size][0]
          @height = options[:size][1]
        elsif options[:size]
          @width = options[:size]
          @height = options[:size]
        elsif file
          if file =~ /_(\d+)x(\d+)/
            # Auto-detect width/height from filename
            # Tilefile foo_10x25.png would mean frame width 10px and height 25px
            @width = $1.to_i
            @height = $2.to_i
          else
            # Assume the shortest side of the actual file is the width/height for each frame
            image = Gosu::Image.new($window, file)
            @width = @height = (image.width < image.height) ? image.width : image.height
           end
        else
          @width = @height = (image.width < image.height) ? image.width : image.height
        end
        
        @frames = Gosu::Image.load_tiles($window, image || file, @width, @height, true)
      end
    end
    
    #
    # Remove transparent space from each frame so the actual sprite is touching the border of the image.
    # This requires TexPlay
    #
    def trim
      #@frames.each do |frame|
      #  y = 0
      #  x2, y2, color = frame.line 0,y,frame.width,y, :trace => { :while_color => :alpha }
      #  puts "final y: #{y}"
      #  #frame.image.trace 0,0,image
      #  #frame.splice(frame,0,0, :crop => [10, 10, 20, 20])
      #end
    end
    
    #
    # Put name on specific ranges of frames.
    # Eg. name_frames(:default => 0..3, :explode => 3..8)
    #
    # Can then be accessed with @animation[:explode]
    #
    def frame_names=(names)
      names.each do |key, value|
        @sub_animations[key] = self.new_from_frames(value)  if value.is_a? Range
        @sub_animations[key] = @frames[value]               if value.is_a? Fixnum
        #
        # TODO: Add support for [1,4,5] array frame selection
        #
        # @frame_names[key] = self.new_from_frames(value) if value.is_a? Array
      end
    end
    
    #
    # Return frame names in { :name => range } -form
    #
    def frame_names
      @frame_names
    end
    
    def animations
      @sub_animations.keys
    end
    
    #
    # Returns the first frame (Gosu::Image) from animation
    #
    def first
      @frames.first
    end

    #
    # Returns the last frame (Gosu::Image) from animation
    #
    def last
      @frames.last
    end
    
    #
    # [width, height] for each frame in the animation
    #
    def size
      [@width, @height]
    end
		
		#
		# Returns true if the current frame is the last
		#
		def last_frame?
			@previous_index == @index
		end
    
    #
    # Fetch a frame or frames:
    #
    #   @animation[0]         # returns first frame
    #   @animation[0..2]      # returns a new Animation-instance with first, second and third frame
    #   @animation[:explode]  # returns a cached Animation-instance with frames earlier set with @animation.frame_names = { ... }
    #
    def [](index)
      return @frames[index]               if  index.is_a?(Fixnum)
      return self.new_from_frames(index)  if  index.is_a?(Range)
      return @sub_animations[index]       if  index.is_a?(Symbol)
    end

    #
    # Manually initialize a frame-range with an Animation-instance
    #
    #   @animation[:scan] = Animation.new(...)
    #
    def []=(name, animation)
      @sub_animations[name] = animation
      return @sub_animations[name]
    end

    #
    # Get the current frame (a Gosu::Image)
    #
    def image
      @frames[@index]
    end
		
    #
    # Resets the animation, re-starts it at frame 0
    # returns itself.
    #
    def reset
      @index = 0
      self
    end
    alias :reset! :reset
		
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
    # Animation#next() will look at bounce and loop flags to always return a correct frame (a Gosu#Image)
    #
    def next(recursion = true)
        
      if (@dt += $window.milliseconds_since_last_tick) >= @delay
        @dt = 0
        @previous_index = @index
        @index += @step
        
        # Has the animation hit end or beginning... time for bounce or loop?
        if (@index >= @frames.size || @index < 0)
          if @bounce
            @step *= -1   # invert number
            @index += @step
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
		alias :next! :next
    
    #
    # Initialize non-blurry zoom on frames in animation
    #
    def retrofy
      frames.each { |frame| frame.retrofy }
      self
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
