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

      module ClassMethods
        def initialize_trait(options = {})
          trait_options[:sprite] = options
        end
      end
      
      attr_accessor :x, :y, :angle, :factor_x, :factor_y, :center_x, :center_y, :zorder, :mode, :visible

      # default settings for all variables unless set in constructor
      DEFAULTS = {
        :x => 0, :y => 0, :angle => 0,
        :factor_x => 1.0, :factor_y => 1.0,
        :zorder => 100, :center_x => 0.5, :center_y => 0.5,
        :mode => :default
      }

      def setup_trait(object_options = {})
        options = DEFAULTS.merge(trait_options[:sprite]).merge(object_options)

        DEFAULTS.merge(options).each do |attr,value|
          self.send("#{attr}=", value)
        end
        
        self.image = options[:image]
        self.color = options[:color]
        super
      end

      def color=(color)
        @color = color.is_a?(Gosu::Color) ? color : Gosu::Color.new(color ||  0xFFFFFFFF)
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
                   Gosu::Image.new($window, image) rescue Gosu::Image[image]
                 elsif image.respond_to? :call
                   image.call
                 else
                   image
                 end
      end

      #
      # Our encapsulation of GOSU's image.draw_rot, uses the objects variables to draw it on screen if @visible is true
      #
      def draw
        draw_relative
      end

      #
      # Works as #draw() but takes offsets for all draw_rot()-arguments. Used among others by the viewport-trait.
      #      
      def draw_relative(x=0, y=0, zorder=0, angle=0, center_x=0, center_y=0, factor_x=0, factor_y=0)
        @image.draw_rot(@x+x, @y+y, @zorder+zorder, @angle+angle, @center_x+center_x, @center_y+center_y, @factor_x+factor_x, @factor_y+factor_y, @color, @mode) if @visible
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
