class GameOver < Chingu::GameState
  def initialize(options)
    super
    @title = Chingu::Text.new(:text=>"Game Over! Hit Space to continue.", :x=>150, :y=>200, :size=>40, :color => Color.new(0xFFFFFF00))
    self.input = { :space => :restart }
  end
  
  def back_to_menu
    clear_game_states
    push_game_state(Menu)
  end

  def draw
    previous_game_state.update    # Draw prev game state onto screen (in this case our level)
    previous_game_state.draw      # Draw prev game state onto screen (in this case our level)
    super                         # Draw game objects in current game state, this includes Chingu::Texts
  end  
end
