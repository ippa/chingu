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
    include Chingu::GameStateHelpers  # Easy access to the global game state-queue
    include Chingu::DrawHelpers       # Adds fill(), fade() etc to each game state
        
    attr_reader :options              # so jac can access his :level-number
    attr_reader :game_objects, :do_setup
    attr_accessor :input
    
    def initialize(options = {})
      @options = options
      @input = options[:input]
      @do_setup = options[:setup] || true
      
      @game_objects = Array.new
      $window.game_state_manager.inside_state = self
    end
    
    #
    # An unique identifier for the GameState-class, 
    # Used in game state manager to keep track of created states.
    #
    def to_sym
      self.class.to_s.to_sym
    end
    
    def add_game_object(game_object)
      @game_objects.push(game_object) unless @game_objects.include?(game_object)
    end
    
    def setup
      # Your game state setup logic here.
    end
    
    #
    # Called when a button is pressed and a game state is active
    #
    def button_down(id)
    end
    
    #
    # Called when a button is released and a game state active
    #
    def button_up(id)
    end
    
    #
    # Calls update on each game object that has current game state as parent (created inside that game state)
    #
    def update
      @game_objects.each { |object| object.update }
    end
    
    #
    # Calls Draw on each game object that has current game state as parent (created inside that game state)
    #
    def draw
      @game_objects.each { |object| object.draw }
    end
  end
end