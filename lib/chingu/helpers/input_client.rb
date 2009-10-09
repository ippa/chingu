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
  module Helpers
  
    #
    # Input-handler mixin that adds #input= and #input
    # 
    # #input= does 2 things:
    # 1) Initialized an inputmap
    # 2) notifies the parent (could be main Window or a GameState) that the object wants input
    #
    # In Chingu this is mixed into Window, GameState and GameObject
    #
    module InputClient
      def input=(input_map)
        @input = input_map
        
        if @parent 
          if (@input == nil || @input == {})
            @parent.remove_input_client(self)
          else
            @parent.add_input_client(self)
          end
        end
      end
      
      def input
        @input
      end
    end
  end
end