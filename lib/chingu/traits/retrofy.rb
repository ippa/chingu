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
    # A chingu trait providing easier handling of the "retrofy" effect (non-blurry zoom)
    # Aims to help out when using scaling with "factor" to create a retrofeeling with big pixels.
    # Provides screen_x and screen_y which takes the scaling into account
    # Also provides new code for draw() which uses screen_x / screen_y instead of x / y
    #
    module Retrofy
    
      #def setup_trait(options)
      #  @retrofy_options = {:debug => false}.merge(options)        
      #  super
      #end

      def retrofied_x=(x)
        self.x = x / self.factor
      end

      def retrofied_y=(y)
        self.y = y / self.factor
      end

      def real_x
        (self.x / self.factor).to_i
      end

      def real_y
        (self.y / self.factor).to_i
      end

      def retrofied_x
        (self.x * self.factor).to_i
      end

      def retrofied_y
        (self.y * self.factor).to_i
      end

      # Returns true if object is inside the game window, false if outside
      # this special version takes @factor into consideration
      def inside_window?
        self.x >= 0 && self.x <= $window.width/self.factor && self.y >= 0 && self.y <= $window.height/self.factor # FIXME what if $window is nil?
      end

      # Returns true object is outside the game window 
      # this special version takes @factor into consideration
      def outside_window?
        not inside_window?
      end      
      
      def draw
        self.image.draw_rot(self.screen_x, self.screen_y, self.zorder, self.angle, self.center_x, self.center_y, self.factor_x, self.factor_y, self.color, self.mode)
      end
    end
  end
end
