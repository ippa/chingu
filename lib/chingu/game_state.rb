module Chingu
  class GameState
    include Chingu::GameStateHelpers  # Easy access to the global game_state-queue
    include Chingu::DrawHelpers       # Adds fill(), fade() etc to each gamestate.
        
    attr_reader :options              # so jac can access his :level-number
    attr_reader :game_objects
    attr_accessor :keymap
    
    def initialize(options = {})
      @options = options
      @game_objects = Array.new
      @keymap = nil
      $window.game_state_manager.inside_state = self
      setup
    end
    
    def add_game_object(game_object)
      @game_objects.push(game_object) unless @game_objects.include?(game_object)
    end
    
    def setup
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