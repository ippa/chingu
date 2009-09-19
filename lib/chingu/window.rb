module Chingu

  class Window < Gosu::Window
    # adds push_game_state, pop_game_state, current_game_state and previous_game_state
    include Chingu::GameStateHelpers    
    
    # adds fill() etc...
    include Chingu::GFXHelpers
    
    # adds game_objects_of_class etc ...
    include Chingu::GameObjectHelpers
    
    # Input dispatch helpers
    include Chingu::InputDispatcher
    
    # input= and input
    include Chingu::InputClient
    
    attr_reader :root, :game_state_manager, :game_objects, :milliseconds_since_last_tick
    
    #
    # See http://www.libgosu.org/rdoc/classes/Gosu/Window.html
    #
    # On top of that we add:
    # - Default widht / height, --fullscreen option from console
    # - Global variable $window
    # - Standard #update which updates all Chingu::GameObject's 
    # - Standard #draw which goes through 
    # - Assethandling with Image["picture.png"] and Sample["shot.wav"]
    # - Default input mapping escape to close 
    #
    def initialize(width = 800, height = 600, fullscreen = false, update_interval = 16.666666)
      fullscreen ||= ARGV.include?("--fullscreen")
      $window = super(width, height, fullscreen, update_interval)
			
      @root = File.dirname(File.expand_path($0))
      Gosu::Image.autoload_dirs = [".", File.join(@root, "gfx"), File.join(@root, "media")]
      Gosu::Sample.autoload_dirs = [".", File.join(@root, "sound"), File.join(@root, "media")]
      Gosu::Tile.autoload_dirs = [".", File.join(@root, "gfx"), File.join(@root, "media")]
      Gosu::Song.autoload_dirs = [".", File.join(@root, "sfx"), File.join(@root, "media")]
			
      @game_objects = GameObjectList.new
      @input_clients = Set.new  # Set is like a unique Array with Hash lookupspeed
      
      @fps_counter = FPSCounter.new
      @game_state_manager = GameStateManager.new
      @milliseconds_since_last_tick = 0
    end
    
    def current_parent
      game_state_manager.current_game_state || self
    end
    
    #
    # Frames per second, access with $window.fps or $window.framerate
    #
    def fps
      @fps_counter.fps
    end
    alias :framerate :fps

    #
    # Total amount of game iterations (ticks)
    #
    def ticks
      @fps_counter.ticks
    end
    
    #
    # Mathematical short name for "milliseconds since last tick"
    #
    def dt
      @milliseconds_since_last_tick
    end

    #
    # Chingus core-logic / loop. Gosu will call this each game-iteration.
    #
    def update
      #
      # Register a tick with our rather standard tick/framerate counter. 
      # Returns the amount of milliseconds since last tick. This number is used in all update()-calls.
      # Without this self.fps would return an incorrect value.
      # If you override this in your Chingu::Window class, make sure to call super.
      #
      @milliseconds_since_last_tick = @fps_counter.register_tick      
      
      intermediate_update
    end
    
    #
    # "game logic" update that is safe to call even between Gosus update-calls
    #
    def intermediate_update
      #
      # Dispatch inputmap for main window
      #
      dispatch_input_for(self)
      
      #
      # Dispatch input for all input-clients handled by to main window (game objects with input created in main win)
      #
      @input_clients.each { |game_object| dispatch_input_for(game_object) }
      
      
      #
      # Call update() on all game objects belonging to the main window.
      #
      update_game_objects
      
      #
      # Call update() on all game objects belonging to the current game state.
      #
      update_game_state_manager
    end
    
    # 
    # Chingus main screen manupulation method.
    # If you override this in your Chingu::Window class, make sure to call super.
    # Gosu will call this each game-iteration just after #update
    #
    def draw
      #
      # Draw all game objects associated with the main window.      
      #
      @game_objects.draw
      
      #
      # Let the game state manager call draw on the active game state (if any)
      #
      @game_state_manager.draw
    end
    
    #
    # Call update() on all game objects in main game window.
    #
    def update_game_objects
      @game_objects.update
    end
    
    #
    # Call update() on our game_state_manger
    # -> call update on active state 
    # -> call update on all game objects in that state
    #
    def update_game_state_manager
      @game_state_manager.update
    end

    #
    # By default button_up sends the keyevent to the GameStateManager
    # .. Which then is responsible to send it to the right GameState(s)
    #
    def button_up(id)
      dispatch_button_up(id, self)
      @input_clients.each { |object| dispatch_button_up(id, object) }
      @game_state_manager.button_up(id)
    end
    
    #
    # By default button_down sends the keyevent to the GameStateManager
    # .. Which then is responsible to send it to the right GameState(s)
    #
    def button_down(id)
      dispatch_button_down(id, self)
      @input_clients.each { |object| dispatch_button_down(id, object) }
      @game_state_manager.button_down(id)
    end
  end
end