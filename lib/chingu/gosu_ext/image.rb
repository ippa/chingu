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
#
module Gosu
  class Image


    #
    # Retrofy should be called just after the image is loaded.
    # When retrofied an image will use a non-blurry zoom.
    # This could be used to make each pixel a sharp 4 pixelblock => retrofeeling.
    #
    def retrofy
      Gosu::enable_undocumented_retrofication
      self

      #
      # The below code depends on the bad opengl gem
      # And it could affect other images anyhow... 
      # So let's use Gosu::enable_undocumented_retrofication until further notice.
      #

      #glBindTexture(GL_TEXTURE_2D, self.gl_tex_info.tex_name)
      #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
      #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
      #self
    end

  end

end
