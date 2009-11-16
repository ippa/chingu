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
  # Chingu incorporates a basic push/pop game state system (as discussed here: http://www.gamedev.net/community/forums/topic.asp?topic_id=477320).
  # Game states is a way of organizing your intros, menus, levels.
  # Game states aren't complicated. In Chingu a GameState is a class that behaves mostly like your default Gosu::Window (or in our case Chingu::Window) game loop.
  #
  # # A simple GameState-example
  # class Intro < Chingu::GameState
  #   def update
  #     # game logic here
  #   end
  #
  #   def draw
  #     # screen manipulation here
  #   end
  #        
  #   # Called when we enter the game state
  #   def setup
  #     @player.angle = 0   # point player upwards
  #   end
  #    
  #   # Called when we leave the current game state
  #   def finalize
  #     push_game_state(Menu)   # switch to game state "Menu"
  #   end
  # end
  #

  class GameState
    include Chingu::Helpers::GFX                # Adds fill(), fade() etc to each game state
    include Chingu::Helpers::GameState          # Easy access to the global game state-queue
    include Chingu::Helpers::GameObject         # Adds game_objects_of_class etc ...
    include Chingu::Helpers::InputDispatcher    # Input dispatch-helpers
    include Chingu::Helpers::InputClient        # GameState can have it's own inputmap
    
    attr_reader :options
    attr_accessor :game_state_manager, :game_objects
    
    #
    # Adds a trait or traits to a certain game class
    # Executes a standard ruby "include" the specified module
    #
    def self.has_trait(*traits)
      has_traits(*traits)
    end
    
    # See #has_trait
    def self.has_traits(*traits)
      Array(traits).each do |trait|
        if trait.is_a?(::Symbol) || trait.is_a?(::String)
          include Chingu::Traits.const_get(Chingu::Inflector.camelize(trait))
        end
      end
    end


    def initialize(options = {})
      @options = options
      @game_objects = GameObjectList.new
      @input_clients = Array.new
      
      # Game state mamanger can be run alone
      if defined?($window) && $window.respond_to?(:game_state_manager)
        $window.game_state_manager.inside_state = self
      end
      
      setup_trait(options)
    end
        
    #
    # An unique identifier for the GameState-class, 
    # Used in game state manager to keep track of created states.
    #
    def to_sym
      self.class.to_s.to_sym
    end

    def to_s
      self.class.to_s
    end
    
    def setup
      # Your game state setup logic here.
    end
    
    #
    # Called when a button is pressed and a game state is active
    #
    def button_down(id)
      dispatch_button_down(id, self)
      @input_clients.each { |object| dispatch_button_down(id, object) } if @input_clients
    end
    
    #
    # Called when a button is released and a game state active
    #
    def button_up(id)
      dispatch_button_up(id, self)
      @input_clients.each { |object| dispatch_button_up(id, object) }   if @input_clients
    end
        
    #
    # Calls update on each game object that has current game state as parent (created inside that game state)
    #
    def update
      dispatch_input_for(self)
      
      @input_clients.each { |game_object| dispatch_input_for(game_object) }      
      
      @game_objects.update
    end
    
    #
    # Calls Draw on each game object that has current game state as parent (created inside that game state)
    #
    def draw
      @game_objects.draw
    end

    # Placeholder for trait-system to override
    def setup_trait(options);end
    def update_trait;end
    def draw_trait;end
        
    #
    # Closes game state by poping it off the stack (and activating the game state below)
    #
    def close
      pop_game_state
    end
    
    #
    # Closes main window and terminates the application
    #
    def close_game
      $window.close
    end
  end
end