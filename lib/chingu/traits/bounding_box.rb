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
    
      module ClassMethods
        def initialize_trait(options = {})
          trait_options[:bounding_box] = options
        end
      end
            
      def bounding_box
        width = self.image.width * self.factor_x.abs
        height = self.image.height * self.factor_y.abs
        
        if trait_options[:bounding_box][:scale]
          width = width * trait_options[:bounding_box][:scale]
          height = height * trait_options[:bounding_box][:scale]
        end
        
        x = self.x - (width * self.center_x.abs)
        y = self.y - (height * self.center_y.abs)
        
        return Rect.new(x, y, width, height)
      end
      alias :bb :bounding_box
      
      def draw_trait      
        if trait_options[:bounding_box][:debug]
          $window.draw_rect(self.bounding_box, Chingu::DEBUG_COLOR, Chingu::DEBUG_ZORDER)
        end
        super
      end
      
    end
  end
end