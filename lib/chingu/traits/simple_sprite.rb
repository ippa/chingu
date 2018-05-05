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
    #     trait :simple_sprite
    #   end
    #
    #   Rocket.create(:x => 100, :y => 200)
    #
    # Options:
    #  :image - actual sprite to draw
    #         - see #image= for details as this method is used to set this option
    #  
    # Introducing Variables:
    #  :x, :y, :zorder, :factor_x, :factor_y, :mode, :color, :visible
    #
    module SimpleSprite      
      module ClassMethods
        def initialize_trait(options = {})
          trait_options[:sprite] = options
        end
      end
      
      attr_accessor :x, :y, :angle, :factor_x, :factor_y, :zorder, :mode, :color
      attr_reader :factor, :center, :height, :width, :image     
      attr_accessor :visible # kill this? force use of setter      

      def setup_trait(object_options = {})        
        @visible = true   unless options[:visible] == false
        self.image =  options[:image]  if options[:image]
        self.color =  options[:color] || ::Gosu::Color::WHITE.dup
        self.alpha =  options[:alpha]  if options[:alpha]
        self.mode =   options[:mode] || :default
        self.x =      options[:x] || 0
        self.y =      options[:y] || 0
        self.zorder = options[:zorder] || 100
        
        self.factor = options[:factor] || options[:scale] || $window.factor || 1.0 # FIXME what if $window is nil?
        self.factor_x = options[:factor_x].to_f if options[:factor_x]
        self.factor_y = options[:factor_y].to_f if options[:factor_y]
        
        if self.image
          self.width  = options[:width]   if options[:width]
          self.height = options[:height]  if options[:height]
          self.size   = options[:size]    if options[:size]
        end
        
        super
      end
      
      #
      # Let's have some useful information in to_s()
      #
      def to_s
        "#{self.class.to_s} @ #{x.to_i} / #{y.to_i} " <<
        "(#{width.to_i} x #{height.to_i}) - " <<
        " ratio: #{sprintf("%.2f",width/height)} scale: #{sprintf("%.2f", factor_x)}/#{sprintf("%.2f", factor_y)} angle: #{angle.to_i} zorder: #{zorder} alpha: #{alpha}"
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
                   Gosu::Image.new($window, image,false) rescue Gosu::Image[image] # FIXME what if $window is nil?
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
        [@x, @y, @angle, @factor_x, @factor_y, @color, @mode, @zorder]
      end
  
      #
      # Set all attributes on 1 line
      # Mainly used in combination with game_object1.attributes = game_object2.attributes
      #
      def attributes=(attributes)
        self.x, self.y, self.angle, self.factor_x, self.factor_y, self.color, self.mode, self.zorder = *attributes
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
      
    
      # Get objects alpha-value (internally stored in @color.alpha)
      def alpha
        @color.alpha
      end
    
      # Set objects alpha-value (internally stored in @color.alpha)
      # If out of range, set to closest working value. this makes fading simpler.
      def alpha=(value)
        value = 0   if value < 0
        value = 255 if value > 255
        @color.alpha = value.to_i
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
        @parent.game_objects.hide_game_object(self)  if @parent && @visible == true
        @visible = false
      end
    
      #
      # Enable automatic calling of draw and draw_trait each game loop
      #
      def show!
        @parent.game_objects.show_game_object(self)  if @parent && @visible == false
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
        x >= 0 && x <= $window.width && y >= 0 && y <= $window.height  # FIXME what if $window is nil?
      end

      # Returns true object is outside the game window 
      def outside_window?(x = @x, y = @y)
        not inside_window?(x,y)
      end

      #
      # Our encapsulation of GOSU's image.draw_rot, uses the objects variables to draw it on screen if @visible is true
      #
      def draw
        @image.draw(@x, @y, @zorder, @factor_x, @factor_y, @color, @mode)  if @image
      end

      #
      # Works as #draw() but takes offsets for all draw_rot()-arguments. Used among others by the viewport-trait.
      #      
      def draw_relative(x=0, y=0, zorder=0,  factor_x=0, factor_y=0)
        @image.draw(@x+x, @y+y, @zorder+zorder, @factor_x+factor_x, @factor_y+factor_y, @color, @mode)  if @image
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
