module Chingu
  module GameStateHelpers
    
    #
    # push_gamestate accepts either a class inherited from GameState or an object-instance from such a class.
    #
    # push_gamestate(Intro) is the same as:
    # push_gamestate(Intro.new)
    # 
    # The first line ends upp calling "new" to Intro before activating the newlycreated gamestate.
    #
    def push_gamestate(state)
      if state.is_a? Chingu::GameState
        $window.game_state_manager.push_state(state)
      elsif state.superclass == Chingu::GameState
        $window.game_state_manager.push_state(state.new)
      end
    end
  
    def pop_gamestate
      $window.game_state_manager.pop_state
    end

    def current_gamestate
      $window.game_state_manager.state
    end

    def previous_gamestate
      $window.game_state_manager.previous_state
    end
  end

  module DrawHelpers
    def fill(color)
       $window.draw_quad(0, 0, color, $window.width, 0, color, $window.width, $window.width, color, 0, $window.height, color, 0, :default) 
     end
     
    def fade(options = {})
    end
  end
end