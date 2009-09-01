#
# Debug game state (F1 is default key to start/exit debug win, 'p' to pause game)
#
module Chingu
  module GameStates
    class Debug < Chingu::GameState
      def initialize(options)
        super
        @white = Color.new(255,255,255,255)
        @fade_color = Gosu::Color.new(100,255,255,255)
        
        @font = Gosu::Font.new($window, default_font_name, 15)
        @paused = true
        
        self.input = {:p => :pause, :f1 => :return_to_game, :esc => :return_to_game}
      end
    
      def return_to_game
        game_state_manager.pop_game_state
      end
      
      def pause
        @paused = @paused ? false : true
      end
      
      def update
        game_state_manager.previous_game_state.update unless @paused
      end
      
      def draw
        game_state_manager.previous_game_state.draw

        $window.draw_quad(  0,0,@fade_color,
                            $window.width,0,@fade_color,
                            $window.width,$window.height,@fade_color,
                            0,$window.height,@fade_color,10)
                       
        text = "DEBUG CONSOLE"
        @font.draw(text, $window.width - @font.text_width(text), @font.height, 999)
      end  
    end
  end
end
