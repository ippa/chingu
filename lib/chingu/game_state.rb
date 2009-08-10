module Chingu
  class GameState
    include Chingu::GameStateHelpers  # Easy access to the global game_state-queue
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
    #  An unique identifier for the gamestate-class, used in game state manager to keep track of created states.
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
    
    def button_down(id)
    end
    
    def button_up(id)
    end

    def update
      @game_objects.each { |object| object.update }
    end
    
    def draw
      @game_objects.each { |object| object.draw }
    end
  end
end