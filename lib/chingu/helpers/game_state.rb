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
  # push_game_state accepts either a class inherited from GameState or an object-instance from such a class.
  #
  # It will make call new() on a class, and just push an object.
  #
  module GameState
    def game_states
      game_state_manager.game_states
    end
    
    def push_game_state(state, options = {})
      game_state_manager.push_game_state(state, options)
    end
  
    def pop_game_state(options = {})
      game_state_manager.pop_game_state(options)
    end

    def switch_game_state(state, options = {})
      game_state_manager.switch_game_state(state, options)
    end

    def transitional_game_state(state, options = {})
      game_state_manager.transitional_game_state(state, options)
    end

    def current_game_state
      game_state_manager.current_game_state
    end

    #def previous_game_state
    #  game_state_manager.previous_game_state
    #end
    
    def clear_game_states
      game_state_manager.clear_game_states
    end
  end
  
  end
end