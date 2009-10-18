#--
#
# Chingu -- OpenGL accelerated 2D game framework for Ruby
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++

module Chingu

  #
  # See http://www.libgosu.org/rdoc/classes/Gosu/Window.html
  #
  # On top of that we add:
  # - Default widht / height, --fullscreen option from console
  # - Sets a global variable $window = self, which is then used throughout Chingu
  # - Defaultd #update which updates all game_objects which are not pasued
  # - Default #draw which draws all game_objects which are visible
  # - Default Asset-directories media/, sfx/, gfx/ etc.
  # - Tracking of button_up/button_down etc to enable Chingus pretty inputhandling
  #
  class Window < Gosu::Window
    include Chingu::Helpers::GFX                # Adds fill(), fade() etc to each game state
    include Chingu::Helpers::GameState          # Easy access to the global game state-queue
    include Chingu::Helpers::GameObject         # Adds game_objects_of_class etc ...
    include Chingu::Helpers::InputDispatcher    # Input dispatch-helpers
    include Chingu::Helpers::InputClient        # WIndow has its own inputmap
    
    attr_reader :root, :game_state_manager, :game_objects, :milliseconds_since_last_tick
    
    def initialize(width = 800, height = 600, fullscreen = false, update_interval = 16.666666)
      fullscreen ||= ARGV.include?("--fullscreen")
      $window = super(width, height, fullscreen, update_interval)
			
      @root = File.dirname(File.expand_path($0))
      Chingu::Asset.autoload_dirs = [".", File.join(@root, "gfx"), File.join(@root, "media"), File.join(@root, "sfx")]
      Gosu::Image.autoload_dirs = [".", File.join(@root, "gfx"), File.join(@root, "media")]
      Gosu::Sample.autoload_dirs = [".", File.join(@root, "sound"), File.join(@root, "media")]
      Gosu::Tile.autoload_dirs = [".", File.join(@root, "gfx"), File.join(@root, "media")]
      Gosu::Song.autoload_dirs = [".", File.join(@root, "sfx"), File.join(@root, "media")]
			
      @game_objects = GameObjectList.new
      @input_clients = Array.new
      
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
      @game_objects.update
      
      #
      # Call update() on all game objects belonging to the current game state.
      #

      #
      # Call update() on our game_state_manger
      # -> call update on active states
      # -> call update on all game objects in that state
      #
      @game_state_manager.update
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