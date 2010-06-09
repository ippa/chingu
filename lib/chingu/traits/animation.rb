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
    # A chingu trait providing automatic loading of tile-animations
    #
    # For example:
    # 	class FireBall; has_traits :animation; end;
    #
    # Will automatically load:
    # - fire_ball.png into self.animations[:default]
    # - fire_ball_exploding.png into self.animations[:exploding]
    #
    # Adds accessors animations -> Hash with all animations, hash-key is the name of the animation
    #
    module Animation
    
      module ClassMethods
    
        def initialize_trait(options = {})
          trait_options[:animation] = {:directory => "media", :play => true, :delay => 100}.merge(options)
        end
        
      end
			
      def setup_trait(options)			
        @animation_options = {:debug => false}.merge(options)        
        @animations = load_animations
        super
      end

      #
      # Try loading animation from class-name
      #
      def load_animations
        animations = {}
        glob = "#{trait_options[:animation][:directory]}/#{self.filename}_*"
        puts "Animations? #{glob}" if trait_options[:animation][:debug]
        Dir[glob].each do |tile_file|
          #state = :default
          if tile_file =~ /[a-zA-Z\_+]_*(\d+)x(\d+)_*([a-zA-Z]*)\.(bmp|png)/
          #if tile_file =~ /_*([a-zA-Z]*)\.(bmp|png)\Z/
          #if tile_file =~ /#{self.filename}\.(bmp|png)/
            state = $3.length > 0 ? $3 : "default"            
            animations[state.to_sym] = Chingu::Animation.new(trait_options[:animation].merge(:file => tile_file))
          end
        end
        return animations
      end
      
      def animation
        @animations[:default]
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