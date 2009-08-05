module Chingu
  #
  # A basic class, all your gameobjects / actors should be built on this. Encapsulates
  # Gosus draw_rot and it's parameters. 
  #
  #
  #
	class Actor
		attr_accessor :image, :x, :y, :angle, :center_x, :center_t, :factor_x, :factor_y, :mode
		attr_accessor :update, :draw, :keymap
		attr_accessor :height, :width
		
    #
    # Create a new GameObject. Arguments are given in hash-format:
    # 
    # :x      screen x-coordinate (default 0, to the left)
    # :y      screen y-coordinate (default 0, top of screen)
    # :angle  angle of object, used in draw_rot, default 0 (no rotation)
    # :zorder a gameclass "foo" with higher zorder then gameclass "bar" is drawn on top of "foo".
    # 
    # :update [true|false] Automaticly call #update on object each gameloop. Default +true+.
    # :draw   [true|false] Automaticly call #update on object each gameloop. Default +true+.
    #
		def initialize(options = {})
			
			## draw_rot arguments
			@image = options[:image]
			@x = options[:x] || 0
			@y = options[:y] || 0
			@angle = options[:angle] || 0
			@zorder = options[:zorder] || 100
			@center_x = options[:center_x] || 0.5
			@center_y = options[:center_y] || 0.5
			@factor_x = options[:factor_x] || 1
			@factor_y = options[:factor_y] || 1
			@mode = options[:mode] || 0
			
			# gameloop logic
			@update = options[:update] || true
			@draw = options[:draw] || true

			# sprite/image logic
			@height = options[:height]
			@width = options[:width]

			automatic_update!	if @update
			automatic_draw!		if @draw
		end
		
    #
    # Add self to the list of objects that Chingu calls #update on each update-loop. 
    # This is done by default except if you create a gameobject with {:update => false}
    #
		def automatic_update!
			$window.automatic_update_for(self)
		end
    #
    # Add self to the list of objects that Chingu calls #draw on each update-loop.
    # This is done by default except if you create a gameobject with {:draw => false}
    #		
		def automatic_draw!
			$window.automatic_draw_for(self)
		end
		
		def keymap=(keymap)
			@keymap = keymap
			$window.key_recievers << self		unless $window.key_recievers.include? self
		end
		
    #
    # Override this with your own actor/game-logic
    #
		def update
			
		end
    
    #
    # The core of the gameclass, the draw_rot encapsulation. Draws the sprite on screen.
    #
		def draw
			##@image.draw_rot(@x.to_i, @y.to_i, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @mode)
      @image.draw_rot(@x.to_i, @y.to_i, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y)
      
      #@image.draw_rot(100,100,100,0, 0.5, 0.5, 1, 1, 0)
      #p @image
		end
	end
	
end