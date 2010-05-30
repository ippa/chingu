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
    # Adds accessors animations -> Hash with all animations, hash-key is the name of the animation
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
        
        @animations = load_animations
        @image = @animations.values.first ? @animations.values.first.first : load_image
								
        puts "!!! automatic_assets couldn't find any image for class #{self.class}" unless @image
        super
      end

      #
      # Try loading animation from class-name
      #
      def load_animations
        animations = {}
        glob = "#{trait_options[:automatic_assets][:directory]}/#{self.filename}_*"
        puts "Animations? #{glob}" if trait_options[:automatic_assets][:debug]
        Dir[glob].each do |tile_file|
          if tile_file =~ /[a-zA-Z\_+]_(\d+)x(\d+)_*([a-zA-Z]*)\.(bmp|png)/
            state = $3.length > 0 ? $3 : "default"            
            puts "ANIM: #{tile_file}, width: #{width}, height: #{height}, state: #{state}" if trait_options[:automatic_assets][:debug]
            animations[state.to_sym] = Chingu::Animation.new(:file => tile_file, :delay => trait_options[:automatic_assets][:delay])
          end
        end
        return animations
      end

      #
      # Try loading an image.
      #
      def load_image
        @image_postfixes = ["bmp", "png"]
        @image_postfixes.each do |postfix|
          image_name = "#{self.filename}.#{postfix}"
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
      # Returns all animations, then access invidual states with animations[:explode] etc.
      #
      def animations
        @animations
      end
      
    end
  end
end