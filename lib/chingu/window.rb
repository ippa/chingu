module Chingu
	class Window < Gosu::Window
    # adds push_game_state, pop_game_state, current_game_state and previous_game_state
    include Chingu::GameStateHelpers    
    
    # adds fill() etc...
    include Chingu::DrawHelpers
    
    # adds game_objects_of_class etc ...
    include Chingu::GameObjectHelpers
    
		attr_reader :root, :game_state_manager, :game_objects, :milliseconds_since_last_tick
		attr_accessor :input
    
    # attr_reader :update_list, :draw_list
		
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
		def initialize(width = 640, height = 480)
			full_screen = ARGV.include?("--fullscreen")
			$window = super(width, height, full_screen)
			
			@root = File.dirname(File.expand_path($0))
			Gosu::Image.autoload_dirs = [".", File.join(@root, "gfx"), File.join(@root, "media")]
			Gosu::Sample.autoload_dirs = [".", File.join(@root, "sound"), File.join(@root, "media")]
			Gosu::Tile.autoload_dirs = [".", File.join(@root, "gfx"), File.join(@root, "media")]
			
      @game_objects = []                  
      @fps_counter = FPSCounter.new
			@game_state_manager = GameStateManager.new
      
			self.input = { :escape => close }
		end
    
    def add_game_object(game_object)
      @game_objects.push(game_object) unless @game_objects.include?(game_object)
    end
    
		def fps
			@fps_counter.fps
		end
    
    #
    # By default button_up sends the keyevent to the GameStateManager
    # .. Which then is responsible to send it to the right GameState(s)
    #
    def button_up(id)
      @game_state_manager.button_up(id)
    end
    
    #
    # By default button_down sends the keyevent to the GameStateManager
    # .. Which then is responsible to send it to the right GameState(s)
    #
    def button_down(id)
      @game_state_manager.button_down(id)
    end

    #
    # Standard GOSU main class update
    #
		def update
			@milliseconds_since_last_tick = @fps_counter.tick
      
      dispatch_input
      
      update_game_objects
      
      update_game_state_manager
		end
    
    #
    # Draw all game objects associated with the main window
    # Then let the game state manager call draw on the active game state (if any)
    #
 		def draw
      @game_objects.each { |object| object.draw }
      @game_state_manager.draw
		end
    
    #
    # Call update() on all game objects in main game window.
    #
    def update_game_objects
      @game_objects.each { |object| object.update(@milliseconds_since_last_tick) }
    end
    
    #
    # Call update() on our game_state_manger
    # -> call update on active state 
    # -> call update on all game objects in that state
    #
    def update_game_state_manager
      @game_state_manager.update(@milliseconds_since_last_tick)
    end
    
    #
    # Process inputs for:
    # - Our main game window (self)
    # - .. and all gameobjects connected to it
    # - the active gamestate
    # - ... and all GameObjects connected to it
    #
    def dispatch_input
      [self, @game_state_manager.current_state].each do |object|
        next if object.nil?
        
				dispatch_input_for(object)
        
        object.game_objects.each do |game_object|
          dispatch_input_for(game_object)
        end
			end
    end

    private 
    
    #
    # Dispatches a input for any given object
    #
    def dispatch_input_for(object)
      return if object.nil? || object.input.nil?
      
      object.input.each do |symbol, action|
        if button_down?(Input::SYMBOL_TO_CONSTANT[symbol])
          #puts "#{object.to_s} :#{symbol.to_s} => #{action.to_s}"
          #puts "[#{action.class.to_s} - #{action.class.superclass.to_s}]"         
          if action.is_a? Symbol
            object.send(action)
          elsif action.is_a? Proc
            action.call
          elsif action.is_a? Chingu::GameState
            push_game_state(action)
          elsif action.superclass == Chingu::GameState
            push_game_state(action)
          end
        end
      end
    end
    
	end
end




#		def button_down(id)
#			key_recievers.each do |key_reciever|	
#				key_reciever.keymap.each do |key, action|
#					key_reciever.send(:before_keymap_dispatch)	if key_reciever.respond_to? (:before_keymap_dispatch)
#					if Keymap::constant_to_symbol[id] == key
#						puts "#{key.to_s} => #{action.to_s}"
#						key_reciever.send(action)
#					end
#				end
#			end			
#		end
		
		#def button_up(id)
		#	key_recievers.each do |key_reciever|	
		#		key_reciever.release_keymap.each do |key, action|
		#			if Keymap::Keys[id] == key
		#				key_reciever.send(action)
		#			end
		#		end
		#	end			
		#end
