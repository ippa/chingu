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
  module GameStates
  
    #
    # Premade game state for chingu - A simple pause state.
    # Pause whenever with: 
    #   push_game_state(Chingu::GameStates::Pause)
    #
    # requires the global $window set to the instance of Gosu::Window (automaticly handled if you use Chingu::Window) # FIXME what if $window is nil?
    #
    class Pause < Chingu::GameState
      
      def initialize(options = {})
        super
        @white = Gosu::Color.new(255,255,255,255)
        @color = Gosu::Color.new(200,0,0,0)
        @font = Gosu::Font[35]
        @text = "PAUSED - press ESC to return to game."
      end
    
      def button_up(id)
        pop_game_state(:setup => false) if id == Gosu::KbEscape   # Return the previous game state, dont call setup()
      end
      
      def draw
        previous_game_state.draw    # Draw prev game state onto screen (in this case our level)
        $window.draw_quad(  0,0,@color,
                            $window.width,0,@color,
                            $window.width,$window.height,@color,
                            0,$window.height,@color, Chingu::DEBUG_ZORDER) # FIXME what if $window is nil?
                            
        @font.draw(@text, ($window.width/2 - @font.text_width(@text)/2), $window.height/2 - @font.height, Chingu::DEBUG_ZORDER + 1) # FIXME what if $window is nil?
      end  
    end
  end
end
