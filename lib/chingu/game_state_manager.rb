module Chingu  
  class GameStateManager
    attr_accessor :inside_state
    attr_reader :states
    
    def initialize
      @inside_state = nil
      @states = []
    end

    #
    # Gets the currently active gamestate (top of stack)
    #
    def state
      @states.last
    end

    #
    # Adds a state to the gamestate-stack
    #
    def push_state(state)
      @states.push(state)
    end
    
    #
    # Pops a state off the gamestate-stack
    #
    def pop_state
      @states.pop
    end
    
    #
    # Returns the previous gamestate
    #
    def previous_state
      @states[@states.index(state)-1]
    end
    
    alias :prev_state previous_state
    
    #
    # Pops through all gamestates until matching a given gamestate
    #
    def switch_state(new_state)
      while (state = @states.pop)
        break if state == new_state
      end
    end
    
    #
    # Bellow follows a set of auto-called Gosu::Window methods.
    # We define them game_state_manager so Gosu::Window can call them here.
    # Then the game_state_manager is responsible to resend them to the active state. 
    # Or in the future many states.
    #
    
    #
    # Called before #update when the user pressed a button while the window had the focus. 
    #
    def button_down(id)
      state.button_down(id) if state
    end
    
    #
    # Called when the user released a button. 
    #
    def button_up(id)
      state.button_up(id)   if state
    end
    
    #
    # Calls #update on the current gamestate, if there is one.
    #
    def update
      state.update  if state
    end
    #
    # Calls draw() on the current gamestate, if there is one.
    #
    def draw
      state.draw    if state
    end
  end
end