module Chingu
  #
  # Chingu incorporates a basic push/pop game state system (as discussed here: http://www.gamedev.net/community/forums/topic.asp?topic_id=477320).
  # Game states is a way of organizing your intros, menus, levels.
  # Game states aren't complicated. In Chingu a GameState is a class that behaves mostly like your default Gosu::Window (or in our case Chingu::Window) game loop.
  #
  # # A simple GameState-example
  # class Intro < Chingu::GameState
  #   def update
  #     # game logic here
  #   end
  #
  #   def draw
  #     # screen manipulation here
  #   end
  #        
  #   # Called when we enter the game state
  #   def setup
  #     @player.angle = 0   # point player upwards
  #   end
  #    
  #   # Called when we leave the current game state
  #   def finalize
  #     push_game_state(Menu)   # switch to game state "Menu"
  #   end
  # end
  #

  class GameState
    include Chingu::GameStateHelpers    # Easy access to the global game state-queue
    include Chingu::DrawHelpers         # Adds fill(), fade() etc to each game state
    include Chingu::GameObjectHelpers   # adds game_objects_of_class etc ...
    include Chingu::InputDispatcher     # dispatch-helpers
    include Chingu::InputClient
    
    attr_reader :options                # so jlnr can access his :level-number
    attr_reader :game_objects, :do_setup
    
    def initialize(options = {})
      @options = options
      @do_setup = options[:setup] || true
      
      @game_objects = Set.new
      @input_clients = Set.new  # Set is like a unique Array with Hash lookupspeed
      
      $window.game_state_manager.inside_state = self
    end
    
    #
    # An unique identifier for the GameState-class, 
    # Used in game state manager to keep track of created states.
    #
    def to_sym
      self.class.to_s.to_sym
    end
    
    def add_game_object(object)
      @game_objects << object
    end
    def remove_game_object(object)
      @input_clients.delete(object)
    end
    
    def setup
      # Your game state setup logic here.
    end
    
    #
    # Called when a button is pressed and a game state is active
    #
    def button_down(id)
      dispatch_button_down(id, self)
      @input_clients.each { |object| dispatch_button_down(id, object) }
    end
    
    #
    # Called when a button is released and a game state active
    #
    def button_up(id)
      dispatch_button_up(id, self)
      @input_clients.each { |object| dispatch_button_up(id, object) }
    end
    
    #
    # Calls update on each game object that has current game state as parent (created inside that game state)
    #
    def update(time = 1)
      dispatch_input_for(self)
      @input_clients.each { |game_object| dispatch_input_for(game_object) }      
      
      @game_objects.each { |object| object.update(time) }
    end
    
    #
    # Calls Draw on each game object that has current game state as parent (created inside that game state)
    #
    def draw
      @game_objects.each { |object| object.draw }
    end
    
    #
    # Closes game state by poping it off the stack (and activating the game state below)
    #
    def close
      pop_game_state
    end
    
    #
    # Closes main window and terminates the application
    #
    def close_game
      $window.close
    end
  end
end