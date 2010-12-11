#--
# Part of Chingu -- OpenGL accelerated 2D game framework for Ruby
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# Written/Refactored by Jakub Hozak - jakub.hozak@gmail.com
#
#++

module Chingu
  module Traits

    #
    # A Chingu trait providing ability to be drawn as an image.
    #
    # Example:
    # 
    #   class Rocket < BasicGameObject
    #     trait :sprite, :image => 'rocket.png'
    #   end
    #
    #   Rocket.create
    #
    # Options:
    #  :image - actual sprite to draw
    #         - see #image= for details as this method is used to set this option
    #  
    # Introducing Variables:
    #  :x, :y, :angle, :factor_x, :factor_y, :center_x, :center_y, :zorder, :mode, :visible
    #
    module Sprite
      include Chingu::Helpers::OptionsSetter
      include Chingu::Helpers::RotationCenter    # Adds easy and verbose modification of @center_x and @center_y
      
      module ClassMethods
        def initialize_trait(options = {})
          trait_options[:sprite] = options
        end
      end
      
      attr_accessor :x, :y, :angle, :factor_x, :factor_y, :center_x, :center_y, :zorder, :mode, :visible, :color
      attr_reader :factor, :center, :height, :width, :image     

      def setup_trait(object_options = {})        
        # default settings for all variables unless set in constructor
        defaults = {
          :x => 0, :y => 0, :angle => 0, :factor => ($window.factor||1.0),
          :zorder => 100, :center_x => 0.5, :center_y => 0.5,
          :mode => :default, :color => nil, :visible => true
        }
        
        # if user specs :image take care of it first since width, height etc depends on it.
        self.image = object_options.delete(:image)  if object_options[:image]
        
        set_options(trait_options[:sprite].merge(object_options), defaults)
        
        super
      end

      def color=(color)
        @color = color.is_a?(Gosu::Color) ? color : Gosu::Color.new(color || 0xFFFFFFFF)
      end

      #
      # Accepts String, callable object or any-other non-nil capable
      # of drawing itself on screen.
      #
      # Examples:
      #   image = 'rocket.png'
      #   image = Gosu::Image.new($window, 'rocket.png')
      #     
      #    image = lambda do
      #      # TexPlay is library for Gosu image generation
      #      TexPlay.create_image($window,10,10).paint { circle(5,5,5, :color => :red) }
      #    end
      #
      def image=(image)
        raise ArgumentError.new("No image set") if image.nil?
        
        @image = if String === image
                   # 1) Try loading the image the normal way
                   # 2) Try looking up the picture using Chingus Image-cache
                   Gosu::Image.new($window, image,false) rescue Gosu::Image[image]
                 elsif image.respond_to? :call
                   image.call
                 else
                   image
                 end
      end

      #
      # Get all settings from a game object in one array.
      # Complemented by the GameObject#attributes= setter.
      # Makes it easy to clone a objects x,y,angle etc.
      #
      def attributes
        [@x, @y, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode, @zorder]
      end
  
      #
      # Set all attributes on 1 line
      # Mainly used in combination with game_object1.attributes = game_object2.attributes
      #
      def attributes=(attributes)
        self.x, self.y, self.angle, self.center_x, self.center_y, self.factor_x, self.factor_y, self.color, self.mode, self.zorder = *attributes
      end

      #
      # Set an effective width for the object on screen.
      # Chingu does this by setting factor_x depending on imge.width and width given.
      # Usually better to have a large image and make it smaller then the other way around.
      #
      def width=(width)
        @factor_x = width.to_f / @image.width.to_f  if @image
      end
      
      #
      # Get effective  width by calculating it from image-width and factor_x
      #
      def width
        (@image.width * @factor_x).abs              if @image
      end

      #
      # Set an effective height for the object on screen.
      # Chingu does this by setting factor_x depending on imge.width and width given.
      # Usually better to have a large image and make it smaller then the other way around.
      #
      def height=(height)
        @factor_y = height.to_f / @image.height.to_f  if @image
      end
    
      #
      # Get effective height by calculating it from image-width and factor
      #
      def height
        (@image.height.to_f * @factor_y).abs        if @image
      end

      # Set width and height in one swoop
      def size=(size)
        self.width, self.height = *size
      end
    
      # Get objects width and height in an array
      def size
        [self.width, self.height]
      end
      
      # Quick way of setting both factor_x and factor_y
      def factor=(factor)
        @factor = @factor_x = @factor_y = factor
      end
      alias scale= factor=
      alias scale factor
      
      # Quick way of setting both center_x and center_y
      def center=(center)
        @center_x = @center_y = center
      end
    
      # Get objects alpha-value (internally stored in @color.alpha)
      def alpha
        @color.alpha
      end
    
      # Set objects alpha-value (internally stored in @color.alpha)
      # If out of range, set to closest working value. this makes fading simpler.
      def alpha=(value)
        value = 0   if value < 0
        value = 255 if value > 255
        @color.alpha = value
      end

      #
      # Sets angle, normalize it to between 0..360
      #
      def angle=(value)
        if value < 0
          value = 360+value
        elsif value > 360
          value = value-360
        end
        @angle = value
      end

      #
      # Disable automatic calling of draw and draw_trait each game loop
      #
      def hide!
        @visible = false
      end
    
      #
      # Enable automatic calling of draw and draw_trait each game loop
      #
      def show!
        @visible = true
      end
    
      #
      # Returns true if visible (not hidden)
      #
      def visible?
        @visible == true
      end    


      # Returns true if object is inside the game window, false if outside
      def inside_window?(x = @x, y = @y)
        x >= 0 && x <= $window.width && y >= 0 && y <= $window.height
      end

      # Returns true object is outside the game window 
      def outside_window?(x = @x, y = @y)
        not inside_window?(x,y)
      end

      #
      # Our encapsulation of GOSU's image.draw_rot, uses the objects variables to draw it on screen if @visible is true
      #
      def draw
        @image.draw_rot(@x, @y, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode)  if @image
      end

      #
      # Works as #draw() but takes offsets for all draw_rot()-arguments. Used among others by the viewport-trait.
      #      
      def draw_relative(x=0, y=0, zorder=0, angle=0, center_x=0, center_y=0, factor_x=0, factor_y=0)
        @image.draw_rot(@x+x, @y+y, @zorder+zorder, @angle+angle, @center_x+center_x, @center_y+center_y, @factor_x+factor_x, @factor_y+factor_y, @color, @mode)  if @image
      end

      #
      # Works as #draw() but takes x/y arguments. Used among others by the edit-game state.
      #      
      def draw_at(x, y)
        draw_relative(x,y)
      end
    end
  end
end
