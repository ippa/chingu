module Chingu
  module Components
    class Visual
      
      def initialize(parent_class, options)
        @parent_class = parent_class        
        @parent_class.class_eval do
          attr_accessor :image, :x, :y, :angle, :center_x, :center_y, :factor_x, :factor_y, :color, :mode, :zorder

          # Quick way of setting both factor_x and factor_y
          def factor=(factor)
            @factor_x = @factor_y = factor
          end
          
          # Quick way of setting both center_x and center_y
          def center=(factor)
            @center_x = @center_y = factor
          end

          # Returns true if object is inside the game window, false if outside
          def inside_window?(x = @x, y = @y)
            x >= 0 && x <= $window.width && y >= 0 && y <= $window.height
          end

          # Returns true object is outside the game window 
          def outside_window?(x = @x, y = @y)
            not inside_window?(x,y)
          end
        end
        
      end

      #
      #   :x        screen x-coordinate (default 0, to the left)
      #   :y        screen y-coordinate (default 0, top of screen)
      #   :angle    angle of object, used in draw_rot, (default 0, no rotation)
      #   :zorder   a gameclass "foo" with higher zorder then gameclass "bar" is drawn on top of "foo".
      #   :center_x relative horizontal position of the rotation center on the image. 
      #               0 is the left border, 1 is the right border, 0.5 is the center (default 0.5)
      #   :center_y see center_x. (default 0.5)
      #   :factor_x horizontal zoom-factor, use >1.0 to zoom in. (default 1.0, no zoom).
      #   :factor_y vertical zoom-factor, use >1.0 to zoom in. (default 1.0, no zoom).
      #
      #   :update [true|false] Automaticly call #update on object each gameloop. Default +true+.
      #   :draw   [true|false] Automaticly call #update on object each gameloop. Default +true+.
      #      
      def setup(parent_instance, options)
        @parent_instance = parent_instance
        @parent_instance.instance_eval do
          # draw_rot arguments
          @image = options[:image]          if options[:image].is_a? Gosu::Image
          @image = Image[options[:image]]   if options[:image].is_a? String
          @x = options[:x] || 0
          @y = options[:y] || 0
          @angle = options[:angle] || 0
          @zorder = options[:zorder] || 100
          @center_x = options[:center_x] || options[:center] || 0.5
          @center_y = options[:center_y] || options[:center] || 0.5
          @factor_x = options[:factor_x] || options[:factor] || 1.0
          @factor_y = options[:factor_y] || options[:factor] || 1.0
            
          @color = Gosu::Color.new(options[:color]) if options[:color].is_a? Bignum
          @color = options[:color]                  if options[:color].respond_to?(:alpha)
          @color = Gosu::Color.new(0xFFFFFFFF)      if @color.nil?
          
          @mode = options[:mode] || :default # :additive is also available.
            
          # Shortcuts for draw_rot arguments
          @factor = 1
            
          # gameloop/framework logic
          @update = options[:update] || true
          @draw = options[:draw] || true
        end
        
      end
          
      def update(parent)
      end
      
      #
      # The core of the gameclass, the draw_rot encapsulation. Draws the sprite on screen.
      # Calling #to_i on @x and @y enables thoose to be Float's, for subpixel slow movement in #update
      #
      def draw(parent)
        ## @image.draw_rot(@x.to_i, @y.to_i, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode)
        parent.image.draw_rot(  parent.x.to_i, 
                                parent.y.to_i, 
                                parent.zorder, 
                                parent.angle, 
                                parent.center_x, 
                                parent.center_y, 
                                parent.factor_x, 
                                parent.factor_y, 
                                parent.color, 
                                parent.mode)
      end
    end
  end
end