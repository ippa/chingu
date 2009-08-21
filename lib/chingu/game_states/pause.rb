#
# Premade game state for chingu - A simple pause state.
# Pause whenever with: 
#   push_game_state(Chingu::GameStates::Pause)
#
module Chingu
  module GameStates
    class Pause < Chingu::GameState
      def initialize(options)
        super
        @title = Chingu::Text.new(:text=>"PAUSED", :x=>$window.width/2, :y=>$window.height/2, :size=>40)
        self.input = { :p => :un_pause }
      end
    
      def un_pause
        pop_game_state(:setup => false)    # Return the previous game state, dont call setup()
      end
      
      def draw
        previous_game_state.draw      # Draw prev game state onto screen (in this case our level)
        super                         # Draw game objects in current game state, this includes Chingu::Texts
      end  
    end
  end
end
