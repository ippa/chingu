module Chingu
  #
  # GameStateManger is responsible for keeping track of game states with a simple pop/push stack.
  #
  # Related blogpost: http://gamedevgeek.com/tutorials/managing-game-states-in-c/
  #
  # Chingu::Window automatically creates a @game_state_manager and makes it accessible in our game loop.
  # By default the game loop calls update() / draw() on @game_state_manager
  #
  class GameStateManager
    attr_accessor :inside_state
    
    def initialize
      @inside_state = nil
      @game_states = []
    end

    #
    # Gets the currently active gamestate (top of stack)
    #
    def current_game_state
      @game_states.last
    end
    alias :current current_game_state

    #
    # Returns all gamestates with top of stack first
    #
    def game_states
      @game_states.reverse
    end
    
    #
    # Switch to a given game state, _replacing_ the current active one.
    #
    def switch_game_state(state, options = {})
      options = {:setup => true, :finalize => true}.merge(options)

      new_state = game_state_instance(state)
      
      if new_state
        # Give the soon-to-be-disabled state a chance to clean up by calling finalize() on it.
        current_game_state.finalize   if current_game_state.respond_to?(:finalize) && options[:finalize]
        
        # Call setup
        new_state.setup               if new_state.respond_to?(:setup) && options[:setup]
        
        
        if current_game_state.nil?
          @game_states << new_state
        else
          # Replace last (active) state with new one
          @game_states[-1] = new_state
        end
      end
    end
    alias :switch :switch_game_state
    
    #
    # Adds a state to the game state-stack and activates it
    #
    def push_game_state(state, options = {})
      options = {:setup => true, :finalize => true}.merge(options)

      new_state = game_state_instance(state)
      
      if new_state
        # Give the soon-to-be-disabled state a chance to clean up by calling finalize() on it.
        current_game_state.finalize   if current_game_state.respond_to?(:finalize) && options[:finalize]
        
        # Call setup
        new_state.setup               if new_state.respond_to?(:setup) && options[:setup]
        
        # Push new state on top of stack and therefore making it active
        @game_states.push(new_state)
      end
    end
    alias :push :push_game_state
    
    #
    # Pops a state off the game state-stack, activating the previous one.
    #
    def pop_game_state(options = {})
      options = {:setup => true, :finalize => true}.merge(options)
      
      #
      # Give the soon-to-be-disabled state a chance to clean up by calling finalize() on it.
      #
      current_game_state.finalize    if current_game_state.respond_to?(:finalize) && options[:finalize]
      
      #
      # Activate the game state "bellow" current one with a simple Array.pop
      #
      @game_states.pop

      # Call setup on the new current state
      current_game_state.setup       if current_game_state.respond_to?(:setup) && options[:setup]
    end
    alias :pop :pop_game_state

    #
    # Returns a GameState-instance from either a class or object
    #
    def game_state_instance(state)
      new_state = nil
      #
      # If state is a GameState-instance, just queue it
      #
      if state.is_a? Chingu::GameState
        new_state = state
      #
      # If state is a GameState-class, create it.
      #        
      elsif state.superclass == Chingu::GameState
        new_state = state.new({})
      end
      
      return new_state
    end


    #
    # Returns the previous game state
    #
    def previous_game_state
      @game_states[@game_states.index(current_game_state)-1]
    end
    alias :previous previous_game_state
    
    #
    # Remove all game states from stack
    #
    def clear_game_states
      @game_states.clear
    end
    alias :clear :clear_game_states
    
    #
    # Pops through all game states until matching a given game state
    #
    def pop_until_game_state(new_state)
      while (state = @game_states.pop)
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
      current_game_state.button_down(id) if current_game_state
    end
    
    #
    # Called when the user released a button. 
    #
    def button_up(id)
      current_game_state.button_up(id)  if current_game_state
    end
    
    #
    # Calls #update on the current gamestate, if there is one.
    #
    def update(time = nil)
      current_game_state.update(time)   if current_game_state
    end
    #
    # Calls draw() on the current gamestate, if there is one.
    #
    def draw
      current_game_state.draw           if current_game_state
    end
  end
end