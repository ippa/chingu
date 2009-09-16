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



#
# Premade game state for chingu - A simple pause state.
# Pause whenever with: 
#   push_game_state(Chingu::GameStates::Pause)
#
# requires global $window
#
module Chingu
  module GameStates
    class Pause < Chingu::GameState
      def initialize(options)
        super
        @white = Color.new(255,255,255,255)
        @color = Gosu::Color.new(200,0,0,0)
        @font = Gosu::Font.new($window, default_font_name, 35)
        @text = "PAUSED - press key to continue"
      end
    
      def button_down(id)
        game_state_manager.pop_game_state(:setup => false)    # Return the previous game state, dont call setup()
      end
      
      def draw
        game_state_manager.previous_game_state.draw    # Draw prev game state onto screen (in this case our level)
        $window.draw_quad(  0,0,@color,
                            $window.width,0,@color,
                            $window.width,$window.height,@color,
                            0,$window.height,@color,10)
                            
        @font.draw(@text, ($window.width/2 - @font.text_width(@text)/2), $window.height/2 - @font.height, 999)
      end  
    end
  end
end
