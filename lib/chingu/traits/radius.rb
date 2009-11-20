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
    # Providing a bounding_box and keeps it up to date by reading:
    # image, factor_x, factor_y
    #
    # ...only makes sense with rotation_center = :center
    #
    module Radius
    
      module ClassMethods
        def initialize_trait(options = {})
          @trait_options[:radius] = options
        end
      end
      
      def radius
        width = self.image.width * self.factor_x.abs
        height = self.image.height * self.factor_y.abs
        radius = (width + height) / 2
        radius = radius * trait_options[:radius][:scale] if  trait_options[:radius][:scale]
        return radius
      end
      
      def draw_trait
        if trait_options[:radius][:debug]
          $window.draw_circle(self.x, self.y, self.radius, Chingu::DEBUG_COLOR)
        end
        super
      end
      
    end
  end
end