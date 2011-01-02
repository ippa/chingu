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
  #  Console is the non-gfx variant of
  #
  #
  class Console
    include Chingu::Helpers::GameState          # Easy access to the global game state-queue
    include Chingu::Helpers::GameObject         # Adds game_objects_of_class etc ...
    
    attr_reader :root, :game_state_manager, :game_objects, :milliseconds_since_last_tick, :factor
    
    def initialize(update_interval = 16.666666)			
      @update_interval = update_interval
      @root = File.dirname(File.expand_path($0))
      @game_objects = GameObjectList.new      
      @fps_counter = FPSCounter.new
      @game_state_manager = GameStateManager.new
      @milliseconds_since_last_tick = 0
      @factor = 1
      $window = self
      
      setup
    end
            
    #
    # This is our "game-loop". Will loop forever, with framerate specified and call update()
    # The idea is to be very simular to how a Chingu::Window works.
    #
    def start
      loop do
        t1 = Time.now
        update
        t2 = Time.now
        update_duration = t2 - t1
        
        milliseconds = (@update_interval/1000 - update_duration)
        sleep(milliseconds)  if milliseconds > 0
      end
    end
    alias :show :start

    # Placeholder to be overwritten
    def setup; end;
    
    #
    # Returns self inside GameState.initialize (a game state is not 'active' inside initialize())
    # Or returns current active game state (as in a switched to or pushed game state)
    # ... Falls back to returning $window
    #
    # current_scope is used to make GameObject.all and friends work everywhere.
    #
    def current_scope
      game_state_manager.inside_state || game_state_manager.current_game_state || self
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
  end
end