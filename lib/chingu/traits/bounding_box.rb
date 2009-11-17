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
    # x, y, factor_x, factor_y and rotation_center
    #
    module BoundingBox
      attr_accessor :bounding_box
            
      def setup_trait(options)
        @bounding_box_options = {:debug => false}.merge(options)
        @bounding_box ||= Rect.new(self.x, self.y, 1, 1)
        super
      end
      
      def BB
        @bounding_box
      end
      
      def BB=(rect)
        @bounding_box = rect
      end
      
      #
      # Keep bounding_box up 2 date with how the image looks on the screen
      #
      def update_trait
        if self.image
          # Addapt width / height to scaling
          real_width = self.image.width * self.factor_x.abs
          real_height = self.image.height * self.factor_y.abs
          
          self.bounding_box.x = self.x - (real_width * self.center_x.abs)
          self.bounding_box.y = self.y - (real_height * self.center_y.abs)
        
          self.bounding_box.width = real_width
          self.bounding_box.height = real_height
        end
        
        super
      end      
    end
  end
end