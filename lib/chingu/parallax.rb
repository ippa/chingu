#
# Class for simple parallaxscrolling
# See: http://en.wikipedia.org/wiki/Parallax_scrolling
#
module Chingu
  class Parallax < Chingu::GameObject
    attr_reader :backgrounds

    #
    # repeat: [true|false]  When one background ends within the screen, repeat/loop it
    #
    def initialize(options)
      super(options)
      @repeat = options[:repeat] || true
      @backgrounds = Array.new
    end
    
    #
    # Add one background, either an ParallaxBackground-object or a Hash of options to create one
    #
    def add_background(arg)
      @backgrounds << (arg.is_a?(ParallaxBackground) ? arg : ParallaxBackground.new(arg))
    end
    
    #
    # Shortcut for #add_background
    #
    def <<(arg)
      self.add_background(arg)
    end
    
    #
    # TODO: make use of time here!
    #
    def update(time)
      @backgrounds.each do |background|
        background.x = -@x / background.damping
        background.y =  @y / background.damping
      end
    end
    
    #
    # Draw 
    #
    def draw
      @backgrounds.each do |background|
        #background.image.draw(real_x, real_y, background.zorder)
        background.draw
        
        save_x = background.x
        ## If background lands inside our screen, repeat it
        while (background.x + background.image.width) < $window.width
          background.x +=  background.image.width
          background.draw
          #background.x -=  background.image.width
          #background.image.draw(real_x+background.image.width, real_y, background.zorder)
        end
        background.x = save_x
      end
      self
    end	 
  end
  
  #
  # One background item
  #
  class ParallaxBackground < Chingu::GameObject
    @@zorder_counter = 0
    attr_reader :damping
    
    def initialize(options)
      ## No auto update/draw, the parentclass Parallax takes care of that!
      options.merge!(:draw => false, :update => false)
      
      # If no zorder is given, use a global incrementing counter. First added, furthest behind when drawn.
      options.merge!(:zorder => (@@zorder_counter+=1))  if options[:zorder].nil?
      
      super(options)

      @damping = options[:damping] || 10
    end    
  end
end