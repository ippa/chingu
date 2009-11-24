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


#
# Core extensions to GOSU
# Some of these require the gem 'texplay'
#
module Gosu  
  class Image
    #
    # Returns true if the pixel at x, y is 100% transperant (good for collisiondetection)
    # Requires texplay
    #
    def transparent_pixel?(x, y)
      begin
        self.get_pixel(x,y)[3] == 0
      rescue
        puts "Error in get_pixel at x/y: #{x}/#{y}"
      end
    end
    
    #
    # Retrofy should be called just after the image is loaded.
    # When retrofied an image will use a non-blurry zoom.
    # This could be used to make each pixel a sharp 4 pixelblock => retrofeeling.
    #
    def retrofy
      glBindTexture(GL_TEXTURE_2D, self.gl_tex_info.tex_name)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
      self
    end
  end
end