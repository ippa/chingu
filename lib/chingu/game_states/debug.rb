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
# Debug game state (F1 is default key to start/exit debug win, 'p' to pause game)
#
module Chingu
  module GameStates
    class Debug < Chingu::GameState
      def initialize(options)
        super
        @white = Color.new(255,255,255,255)
        @fade_color = Gosu::Color.new(100,255,255,255)
        
        @font = Gosu::Font.new($window, default_font_name, 15)
        @paused = true
        
        self.input = {:p => :pause, :f1 => :return_to_game, :esc => :return_to_game}
      end
    
      def return_to_game
        game_state_manager.pop_game_state
      end
      
      def pause
        @paused = @paused ? false : true
      end
      
      def update
        game_state_manager.previous_game_state.update unless @paused
      end
      
      def draw
        game_state_manager.previous_game_state.draw

        $window.draw_quad(  0,0,@fade_color,
                            $window.width,0,@fade_color,
                            $window.width,$window.height,@fade_color,
                            0,$window.height,@fade_color,10)
                       
        text = "DEBUG CONSOLE"
        @font.draw(text, $window.width - @font.text_width(text), @font.height, 999)
      end  
    end
  end
end
