#
# Premade game state for chingu - A simple pause state.
# Pause whenever with: 
#   push_game_state(Chingu::GameStates::Pause)
#
# requires global $window
#
module Chingu
  module GameStates
    class Pause < Chingu::GameState
      def initialize(options)
        super
        @white = Color.new(255,255,255,255)
        @color = Gosu::Color.new(200,0,0,0)
        @font = Gosu::Font.new($window, default_font_name, 35)
        @text = "PAUSED - press key to continue"
      end
    
      def button_down(id)
        game_state_manager.pop_game_state(:setup => false)    # Return the previous game state, dont call setup()
      end
      
      def draw
        game_state_manager.previous_game_state.draw    # Draw prev game state onto screen (in this case our level)
        $window.draw_quad(  0,0,@color,
                            $window.width,0,@color,
                            $window.width,$window.height,@color,
                            0,$window.height,@color,10)
                            
        @font.draw(@text, ($window.width/2 - @font.text_width(@text)/2), $window.height/2 - @font.height, 999)
      end  
    end
  end
end
