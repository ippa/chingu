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
    # Premade game state for chingu - Fade between two game states
    # Fade from the current game state to a new one whenever with: 
    #
    #   push_game_state(Chingu::GameStates::FadeTo.new(new_game_state, :speed => 3))
    #
    # .. Or make your whole game look better with 1 line:
    #
    #   transitional_game_state(Chingu::GameStates::FadeTo, :speed => 10)
    #
    class FadeTo < Chingu::GameState
      
      def initialize(new_game_state, options = {})
        @options = {:speed => 3, :zorder => 999999}.merge(options)
        
        @new_game_state = new_game_state
        @new_game_state = new_game_state.new if new_game_state.is_a? Class        
        @new_game_state.game_objects.sync
      end
    
      def setup
        @color = Gosu::Color.new(0,0,0,0)
        
        if previous_game_state
          @fading_in = false
          @alpha = 0.0
        else
          @fading_in = true 
          @alpha = 255.0
        end
        
        update                        # Since draw is called before update
      end
    
      def update
        @alpha += (@fading_in ? -@options[:speed] : @options[:speed])
        @alpha = 0    if @alpha < 0
        @alpha = 255  if @alpha > 255
        
        @fading_in = true   if @alpha == 255
        @color.alpha = @alpha.to_i
        @drawn = false
      end
      
      def draw
        # Stop possible endless loops
        if @drawn == false
          @drawn = true
          
          if @fading_in
            @new_game_state.draw
          else
            previous_game_state.draw
          end
      
          $window.draw_quad( 0,0,@color,
                              $window.width,0,@color,
                              $window.width,$window.height,@color,
                              0,$window.height,@color,@options[:zorder])
        end
        
        if @fading_in && @alpha == 0
          switch_game_state(@new_game_state, :transitional => false)
        end
                            
      end
    end
  end
end