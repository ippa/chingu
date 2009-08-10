module Chingu
  module GameStateHelpers
    
    #
    # push_state accepts either a class inherited from GameState or an object-instance from such a class.
    #
    # push_state(Intro):
    # game state mananger will create a new Intro-object first time called and cache it.
    #
    # push_state(Intro.new):
    # 
    # 
    # The first line ends upp calling "new" to Intro before activating the newlycreated state.
    #
    def push_state(state, options = {})
      $window.game_state_manager.push_state(state, options)      
    end
  
    def pop_state(options)
      $window.game_state_manager.pop_state(options)
    end

    def current_state
      $window.game_state_manager.current_state
    end

    def previous_state
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