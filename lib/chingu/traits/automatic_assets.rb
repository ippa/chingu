#--
#
# Chingu -- OpenGL accelerated 2D game framework for Ruby
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++

module Chingu
  module Traits
    #
    # A chingu trait providing:
    # - automatic detection and loading of images, sounds, animations
    #
    # For example:
    # 	class FireBall; has_traits :automatic_assets; end;
    #
    # Will automatically load fire_ball.png into @image
    #
    # Adds accessors animations, animation and method switch_animation(state)
    #
    module AutomaticAssets
    
      module ClassMethods
    
        def initialize_trait(options = {})
          trait_options[:automatic_assets] = {:directory => "media", :play => true, :delay => 100}.merge(options)
          #initialize_inherited_trait
        end
      
        #def asset_label
        #  Chingu::Inflector.underscore(self.to_s)
        #end
      
        #def initialize_inherited_trait
        #  trait_options[:automatic_assets][:animations] = load_animation
        #  trait_options[:automatic_assets][:image] = load_image
        #end
      end
			
      def setup_trait(options)			
        @automatic_assets_options = {:debug => false}.merge(options)
        
        @_animation_state = :default
        @_animations = load_animations
        if anim = @_animations.values.first
          @image = anim.frames[0]
        else
          @image = load_image
        end
								
        puts "!!! automatic_assets couldn't find any image for class #{self.class}" unless @image
        super
      end

      #
      # Try loading an image.
      #
      def load_image
        @image_postfixes = ["bmp", "png"]
        @image_postfixes.each do |postfix|
          image_name = "#{self.asset_label}.#{postfix}"
          puts "Trying to load #{image_name}"	if trait_options[:automatic_assets][:debug]
              
          begin
            image = Gosu::Image.new($window, File.join(trait_options[:automatic_assets][:directory], image_name) )
          rescue
            image = Image[image_name] if Image[image_name]
          end
            
          return image if image
        end          
      end

      #
      # Try loading animation from class-name
      #
      def load_animations
        animations = {}
        glob = "#{trait_options[:automatic_assets][:directory]}/#{self.asset_label}_*"
        puts "Animations? #{glob}" if trait_options[:automatic_assets][:debug]
        Dir[glob].each do |tile_file|
          if tile_file =~ /[a-zA-Z\_+]_(\d+)x(\d+)_*([a-zA-Z]*)\.(bmp|png)/
            width = $1.to_i
            height = $2.to_i
            state = $3
            state = "default" if state.length < 1
            
            puts "ANIM: #{tile_file}, width: #{width}, height: #{height}, state: #{state}" if trait_options[:automatic_assets][:debug]
            animations[state.to_sym] = Chingu::Animation.new(:file => tile_file, :size => [width, height], :delay => trait_options[:automatic_assets][:delay])
          end
        end
        return animations
      end			

      
      #
      # Returns a filename-friendly string from the current class-name
      #
      # "FireBall" -> "fire_ball"
      #
      def asset_label
        Chingu::Inflector.underscore(self.class.to_s)
      end
      
      #
      # Returns all animations, then access invidual states with animations[:explode] etc.
      #
      def animations
        @_animations
      end

      #
      # Return the current playing animation
      #
      def animation
        @_animations[@_animation_state]
      end
			
      #
      # Change animation-state: star_10x10_<state>.png
      # For example switch_animation(:exploding) will animation something_10x10_exploding.png
      #
      def switch_animation(state)
        @_animation_state = state
        animation
      end
      
      def update_trait
        if animation && trait_options[:automatic_assets][:play]
          self.image = animation.next	
        end
        super
      end
      
    end
  end
end