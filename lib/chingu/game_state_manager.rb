module Chingu  
  class GameStateManager
    attr_accessor :inside_state
    attr_reader :states
    
    def initialize
      @inside_state = nil
      @states = []
      @created_states = {}
    end

    #
    # Gets the currently active gamestate (top of stack)
    #
    def current_state
      @states.last
    end

    #
    # Adds a state to the gamestate-stack
    #
    def push_state(state, options = {})
      new_state = nil

      #
      # If state is a GameState-instance, just queue it
      #
      if state.is_a? Chingu::GameState
        new_state = state
      #
      # If state is a GameState-class, create/initialize it once (@created_states keeps track of this)
      #        
      elsif state.superclass == Chingu::GameState
        
        if @created_states[state.to_s]
          new_state = @created_states[state.to_s]
        else
          new_state = state.new(options)
          @created_states[state.class.to_s] = new_state
        end
      end

      #
      # If the new state is all good
      #
      if new_state
        # Give the soon-to-be-disabled state a chance to clean up by calling finalize() on it.
        current_state.finalize  if current_state.respond_to? :finalize
        
        # Call setup
        new_state.setup         if new_state.do_setup
        
        # Push new state on top of stack and therefore making it active
        @states.push(new_state)
      end
    end
    
    #
    # Pops a state off the gamestate-stack
    #
    def pop_state(options = {})
      #
      # Give the soon-to-be-disabled state a chance to clean up by calling finalize() on it.
      #
      current_state.finalize  if current_state.respond_to? :finalize
      
      #
      # Activate the game state "bellow" current one with a simple Array.pop
      #
      @states.pop

      # Call setup on the new current state
      current_state.setup       unless options[:setup] == false
    end
    
    #
    # Returns the previous gamestate
    #
    def previous_state
      @states[@states.index(current_state)-1]
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
      current_state.button_down(id) if current_state
    end
    
    #
    # Called when the user released a button. 
    #
    def button_up(id)
      current_state.button_up(id)   if current_state
    end
    
    #
    # Calls #update on the current gamestate, if there is one.
    #
    def update
      current_state.update  if current_state
    end
    #
    # Calls draw() on the current gamestate, if there is one.
    #
    def draw
      current_state.draw    if current_state
    end
  end
end