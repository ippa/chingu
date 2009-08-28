module Chingu
  #
  # GameStateManger is responsible for keeping track of game states with a simple pop/push stack.
  #
  # More about the concept of states in games:
  # http://gamedevgeek.com/tutorials/managing-game-states-in-c/
  # http://www.gamedev.net/community/forums/topic.asp?topic_id=477320
  #
  # Chingu::Window automatically creates a @game_state_manager and makes it accessible in our game loop.
  # By default the game loop calls update(dt), draw, button_up(id) and button_down(id) on the active state.
  #
  # ==== Chingu Examples
  #
  # Enter a new game state, Level, don't call finalize() on the game state we're leaving.
  #   push_game_state(Level, :finalize => false)
  #
  # Return to the previous game state, don't call setup() on it when it becomes active.
  #   pop_game_state(:setup => false)
  #
  # If you want to use Chingus GameStateManager _without_ Chingu::Windoe, see example5.rb
  #
  class GameStateManager
    attr_accessor :inside_state
    
    def initialize
      @inside_state = nil
      @game_states = []
      @transitional_game_state = nil
      @transitional_game_state_options = {}
      @previous_game_state = nil
    end
    
    #
    # Gets the currently active gamestate (top of stack)
    #
    def current_game_state
      @game_states.last
    end
    alias :current current_game_state

    #
    # Returns all gamestates with currenlty active game state on top.
    #
    def game_states
      @game_states.reverse
    end
    
    #
    # Sets a game state to be called between the old and the new game state 
    # whenever a game state is switched,pushed or popped.
    #
    # The transitional game state is responsible for switching to the "new game state".
    # It should do so with ":transitional => false" not to create an infinite loop.
    # 
    # The new game state is the first argument to the transitional game states initialize().
    #
    # Example:
    #   transitional_game_state(FadeIn)
    #   push_game_state(Level2)
    #
    # would in practice become:
    # 
    #   push_game_state(FadeIn.new(Level2))
    #
    # This would be the case for every game state change until the transitional game state is removed:
    #   transitional_game_state(nil)  # or false
    #
    # Very useful for fading effect between scenes.
    #
    def transitional_game_state(game_state, options = {})
      @transitional_game_state = game_state
      @transitional_game_state_options = options
    end
    
    #
    # Switch to a given game state, _replacing_ the current active one.
    # By default setup() is called on the game state  we're switching _to_.
    # .. and finalize() is called on the game state we're switching _from_.
    #
    def switch_game_state(state, options = {})
      options = {:setup => true, :finalize => true, :transitional => true}.merge(options)

      new_state = game_state_instance(state)
      
      if new_state
        # Make sure the game state knows about the manager
        new_state.game_state_manager = self
        
        
        # Give the soon-to-be-disabled state a chance to clean up by calling finalize() on it.
        @previous_game_state = current_game_state
        current_game_state.finalize   if current_game_state.respond_to?(:finalize) && options[:finalize]
        
        # Call setup
        new_state.setup               if new_state.respond_to?(:setup) && options[:setup]
        
        if @transitional_game_state && options[:transitional]
          # If we have a transitional, switch to that instead, with new_state as first argument
          transitional_game_state = @transitional_game_state.new(new_state, @transitional_game_state_options)
          self.switch_game_state(transitional_game_state, :transitional => false)
        else
          if current_game_state.nil?
            @game_states << new_state
          else
            # Replace last (active) state with new one
            @game_states[-1] = new_state
          end
        end
        self.inside_state = current_game_state
      end
    end
    alias :switch :switch_game_state
    
    #
    # Adds a state to the game state-stack and activates it.
    # By default setup() is called on the new game state 
    # .. and finalize() is called on the game state we're leaving.
    #
    def push_game_state(state, options = {})
      options = {:setup => true, :finalize => true, :transitional => true}.merge(options)

      new_state = game_state_instance(state)
            
      if new_state
        # Call setup
        new_state.setup               if new_state.respond_to?(:setup) && options[:setup]
        
        # Make sure the game state knows about the manager
        new_state.game_state_manager = self
        
        # Give the soon-to-be-disabled state a chance to clean up by calling finalize() on it.
        @previous_game_state = current_game_state
        current_game_state.finalize   if current_game_state.respond_to?(:finalize) && options[:finalize]
        
        if @transitional_game_state && options[:transitional]
          # If we have a transitional, push that instead, with new_state as first argument
          transitional_game_state = @transitional_game_state.new(new_state, @transitional_game_state_options)
          self.push_game_state(transitional_game_state, :transitional => false)
        else
          # Push new state on top of stack and therefore making it active
          @game_states.push(new_state)
        end
        self.inside_state = current_game_state
      end
    end
    alias :push :push_game_state
    
    #
    # Pops a state off the game state-stack, activating the previous one.
    # By default setup() is called on the game state that becomes active.
    # .. and finalize() is called on the game state we're leaving.
    #
    def pop_game_state(options = {})
      options = {:setup => true, :finalize => true, :transitional => true}.merge(options)
      
      #
      # Give the soon-to-be-disabled state a chance to clean up by calling finalize() on it.
      #
      @previous_game_state = current_game_state
      current_game_state.finalize    if current_game_state.respond_to?(:finalize) && options[:finalize]

      #
      # Activate the game state "bellow" current one with a simple Array.pop
      #
      @game_states.pop
        
      # Call setup on the new current state
      current_game_state.setup       if current_game_state.respond_to?(:setup) && options[:setup]
      
      if @transitional_game_state && options[:transitional]
        # If we have a transitional, push that instead, with new_state as first argument
        transitional_game_state = @transitional_game_state.new(current_game_state, @transitional_game_state_options)
        self.switch_game_state(transitional_game_state, :transitional => false)
      end
      self.inside_state = current_game_state
    end
    alias :pop :pop_game_state

    #
    # Returns the previous game state. Shortcut: "previous"
    #
    def previous_game_state
      ##@game_states[@game_states.index(current_game_state)-1]
      @previous_game_state
    end
    alias :previous previous_game_state
    
    #
    # Remove all game states from stack. Shortcut: "clear"
    #
    def clear_game_states
      @game_states.clear
      self.inside_state = nil
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
    # This method should be called from button_down(id) inside your main loop.
    # Enables the game state manager to call button_down(id) on active game state.
    #
    # If you're using Chingu::Window instead of Gosu::Window this will automaticly be called.
    #
    def button_down(id)
      current_game_state.button_down(id) if current_game_state
    end
    
    #
    # This method should be called from button_up(id) inside your main loop.
    # Enables the game state manager to call button_up(id) on active game state.
    #
    # If you're using Chingu::Window instead of Gosu::Window this will automaticly be called.
    #
    def button_up(id)
      current_game_state.button_up(id)  if current_game_state
    end
    
    #
    # This method should be called from update() inside your main loop.
    # Enables the game state manager to call update() on active game state.
    #
    # If you're using Chingu::Window instead of Gosu::Window this will automaticly be called.
    #
    def update(time = nil)
      current_game_state.update(time)   if current_game_state
    end

    #
    # This method should be called from draw() inside your main loop.
    # Enables the game state manager to call update() on active game state.
    #
    # If you're using Chingu::Window instead of Gosu::Window this will automaticly be called.
    #
    def draw
      current_game_state.draw           if current_game_state
    end
    
    private
    
    #
    # Returns a GameState-instance from either a GameState class or GameState-object
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
    
  end
end