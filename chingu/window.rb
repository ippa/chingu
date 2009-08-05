module Chingu
	class Window < Gosu::Window
		attr_reader :root, :keymap, :update_list, :draw_list, :tick
		attr_accessor :key_recievers
		
		def initialize(width = nil, height = nil)
			@width = width || 640
			@height = height || 480
			full_screen = ARGV.include?("--fullscreen")
			$window = super(@width, @height, full_screen)
			
			@root = File.dirname(File.expand_path($0))
			Image.autoload_dirs = [".", File.join(@root, "gfx"), File.join(@root, "media")]
			Sample.autoload_dirs = [".", File.join(@root, "sound"), File.join(@root, "media")]
			Tile.autoload_dirs = [".", File.join(@root, "gfx"), File.join(@root, "media")]
			
			@ticks = 0
			@fps_counter = FPSCounter.new
			@last_tick = Gosu::milliseconds
			@key_recievers = []
			@update_list = []
			@draw_list = []
			self.keymap = { :escape => close }
		end

		def automatic_update_for(object)
			@update_list << object	unless @update_list.include?(self)
		end
		
		def automatic_draw_for(object)
			@draw_list << object		unless @draw_list.include?(self)
		end

		def keymap=(keymap)
			@keymap = keymap
			$window.key_recievers << self		unless $window.key_recievers.include? self
		end
		
		def update_tick
			@tick = Gosu::milliseconds - @last_tick
			@last_tick = Gosu::milliseconds
			@tick
		end
	
		def fps
			@fps_counter.fps
		end
	
		def update
			@fps_counter.register_tick
			update_tick
						
			key_recievers.each do |key_reciever|	
				key_reciever.keymap.each do |symbol, action|
					if button_down?(Keymap::SYMBOL_TO_CONSTANT[symbol])
						key_reciever.send(action)
					end
				end
			end
			
			@update_list.each { |object| object.update }
		end
		
		def draw
			@draw_list.each { |object| object.draw }
		end
    
    #
    # TODO: Move this into it's own file
    #
		def fill(color)
			self.draw_quad(0, 0, color, self.width, 0, color, self.width, self.width, color, 0, self.height, color, 0, :default) 
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
