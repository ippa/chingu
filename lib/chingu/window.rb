module Chingu
	class Window < Gosu::Window
    include Chingu::GameStateHelpers    # adds push_gamestate(), pop_gamestate() and previous_gamestate()
    include Chingu::DrawHelpers         # adds fill() etc..
    
		attr_reader :root, :update_list, :draw_list, :tick, :game_state_manager
		attr_accessor :key_receivers, :keymap
    attr_reader :game_objects
		
    #
    # See http://www.libgosu.org/rdoc/classes/Gosu/Window.html
    #
    # On top of that we add:
    # - Default widht / height, --fullscreen option from console
    # - Global variable $window
    # - Standard #update which updates all Chingu::GameObject's 
    # - Standard #draw which goes through 
    # - Assethandling with Image["picture.png"] and Sample["shot.wav"]
    # - Default keymap mapping escape to close 
    #
		def initialize(width = 640, height = 480)
			full_screen = ARGV.include?("--fullscreen")
			$window = super(width, height, full_screen)
			
			@root = File.dirname(File.expand_path($0))
			Gosu::Image.autoload_dirs = [".", File.join(@root, "gfx"), File.join(@root, "media")]
			Gosu::Sample.autoload_dirs = [".", File.join(@root, "sound"), File.join(@root, "media")]
			Gosu::Tile.autoload_dirs = [".", File.join(@root, "gfx"), File.join(@root, "media")]
			
      @game_objects = []
      @keymap = nil
      
			@ticks = 0
			@last_tick = Gosu::milliseconds
      
      @fps_counter = FPSCounter.new
			@game_state_manager = GameStateManager.new
      
			@update_list = []
			@draw_list = []
      
			self.keymap = { :escape => close }
		end
    
    def add_game_object(game_object)
      @game_objects.push(game_object) unless @game_objects.include?(game_object)
    end

		def update_tick
			@tick = Gosu::milliseconds - @last_tick
			@last_tick = Gosu::milliseconds
			@tick
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
			@fps_counter.register_tick
			update_tick

      #
      # Process keymaps for:
      # - Our main game window (self)
      # - .. and all gameobjects connected to it
      # - the active gamestate
      # - ... and all GameObjects connected to it
      #
      [self, @game_state_manager.state].each do |object|
        next if object.nil?
        
				dispatch_keymap_for(object)
        
        object.game_objects.each do |game_object|
          dispatch_keymap_for(game_object)
        end
			end

      @game_objects.each { |object| object.update }
      @game_state_manager.update
		end
    
 		def draw
      @game_objects.each { |object| object.draw }
      @game_state_manager.draw
		end

    private 
    
    #
    # Dispatches a keymap for any given object
    #
    def dispatch_keymap_for(object)
      return if object.nil? || object.keymap.nil?
      
      object.keymap.each do |symbol, action|
        if button_down?(Keymap::SYMBOL_TO_CONSTANT[symbol])
          # puts "#{object.to_s} :#{symbol.to_s} => #{action.to_s}"
          # puts "[#{action.class.to_s} - #{action.class.superclass.to_s}]"
          
          if action.is_a? Symbol
            object.send(action)
          elsif action.is_a? Proc
            action.call
          elsif action.is_a? Chingu::GameState
            push_gamestate(action)
          elsif action.superclass == Chingu::GameState
            push_gamestate(action)
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
