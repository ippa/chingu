#--
#
# Chingu -- Game framework built on top of the opengl accelerated gamelib Gosu
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
    # Aims to help out when using zoom-factor to create a retrofeeling with big pixels.
    # Provides screen_x and screen_y which takes the zoom into account
    # Also provides new code for draw() which uses screen_x / screen_y instead of x / y
    #
    module Retrofy
      
      def setup_trait(options)
        @retrofy_options = {:debug => false}.merge(options)        

        super
      end
      
      def screen_width
        (@image.width * self.factor).to_i
      end

      def screen_height
        (@image.heigt * self.factor).to_i
      end

      def screen_x
        (@x * self.factor).to_i
      end

      def screen_y
        (@y * self.factor).to_i
      end
      
      def draw
        @image.draw_rot(self.screen_x, self.screen_y, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode)
      end
      
    end
  end
end