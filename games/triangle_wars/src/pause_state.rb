class Pause < Chingu::GameState
  def initialize(options)
    super
    @title = Chingu::Text.new(:text=>"PAUSED ('P' to un-pause)", :x=>150, :y=>200, :size=>40, :color => Color.new(0xFFFFFF00))
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
