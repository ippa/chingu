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
    # Providing a bounding_box-method which generates a AABB on the fly from:
    # x, y, factor_x, factor_y and rotation_center
    #
    module BoundingBox
      CENTER_TO_FACTOR = { 0 => -1, 0.5 => 0, 1 => 1 }
      attr_accessor :collidable
    
      module ClassMethods
        def initialize_trait(options = {})
          trait_options[:bounding_box] = options
        end
      end
      
      def setup_trait(options)
        @cached_bounding_box = nil
        @collidable = true
        super
      end
      
      def collision_at?(x, y)
        bounding_box.collide_point?(x,y)
      end
      
      #
      # Returns an instance of class Rect
      #
      def bounding_box        
        if @cached_bounding_box
          @cached_bounding_box.x = self.x + @_x_diff
          @cached_bounding_box.y = self.y + @_y_diff
          
          return @cached_bounding_box
        end
        
        width, height = self.width, self.height
        
        if scale = trait_options[:bounding_box][:scale]
          width_scale, height_scale = scale.is_a?(Array) ? [scale[0],scale[1]] : [scale,scale]
          width  *= width_scale
          height *= height_scale
        end
                
        x = self.x - width * self.center_x
        y = self.y - height * self.center_y
        x += width * CENTER_TO_FACTOR[self.center_x]   if self.factor_x < 0
        y += height * CENTER_TO_FACTOR[self.center_y]  if self.factor_y < 0

        return Rect.new(x, y, width, height)
      end
      alias :bb :bounding_box
      
      def cache_bounding_box
        @cached_bounding_box = nil
        @cached_bounding_box = self.bounding_box
        @_x_diff = @cached_bounding_box.x - self.x
        @_y_diff = @cached_bounding_box.y - self.y
      end
      
      #def update_trait
      #  cache_bounding_box  if trait_options[:bounding_box][:cache] && !@cached_bounding_box
      #  super
      #end
      
      def draw_trait      
        draw_debug if trait_options[:bounding_box][:debug]
        super
      end
      
      #
      # Visualises the bounding box as a red rectangle.
      #
      def draw_debug
        $window.draw_rect(self.bounding_box, Chingu::DEBUG_COLOR, Chingu::DEBUG_ZORDER) # FIXME what if $window is nil?
      end
      
    end
  end
end
