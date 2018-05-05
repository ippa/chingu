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
    include Chingu::Helpers::ClassInheritableAccessor # adds classmethod class_inheritable_accessor
    
    attr_reader :options
    attr_accessor :game_objects, :game_state_manager, :previous_game_state
    
    class_inheritable_accessor :trait_options
    @trait_options = Hash.new
    def trait_options; self.class.trait_options; end
            
    #
    # Adds a trait or traits to a certain game class
    # Executes a standard ruby "include" the specified module
    #
    def self.trait(trait, options = {})
      
      if trait.is_a?(::Symbol) || trait.is_a?(::String)
        ## puts "trait #{trait}, #{options}"
        begin
          # Convert user-given symbol (eg. :timer) to a Module (eg. Chingu::Traits::Timer)
          mod = Chingu::Traits.const_get(Chingu::Inflector.camelize(trait))
          
          # Include the module, which will add the containing methods as instance methods
          include mod
                   
          # Does sub-module "ClassMethods" exists?
          # (eg: Chingu::Traits::Timer::ClassMethods)
          if mod.const_defined?("ClassMethods")
            # Add methods in scope ClassMethods as.. class methods!
            mod2 = mod.const_get("ClassMethods")
            extend mod2
          
            # If the newly included trait has a initialize_trait method in the ClassMethods-scope:
            # ... call it with the options provided with the trait-line.
            if mod2.method_defined?(:initialize_trait)
              initialize_trait(options)
            end
          end
        rescue
          puts $!
        end
      end
    end
    class << self; alias :has_trait :trait;  end
    
    def self.traits(*traits)
      Array(traits).each { |trait| trait trait }
    end
    class << self; alias :has_traits :traits; end

    def initialize(options = {})
      @options = options
      @game_objects = GameObjectList.new
      @input_clients = Array.new
  
      # Game state manager can be run alone
      if defined?($window) && $window.respond_to?(:game_state_manager)
        
        # Since we place the init of previous_game_state here, game states can use it even 
        # in initialize() if they call super first.
        @previous_game_state = $window.game_state_manager.current_game_state
        
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
    
    #
    # Returns a filename-friendly string from the current class-name
    #
    # "Level19" -> "level19"
    # "BigBossLevel" -> "big_boss_level"
    #
    def filename
      Chingu::Inflector.underscore(self.class.to_s)
    end
    
    
    def setup
      # Your game state setup logic here.
    end
    
    #
    # Called when a button is pressed and a game state is active
    #
    def button_down(id)
      dispatch_button_down(id, self)
      @input_clients.each { |object| dispatch_button_down(id, object) unless object.paused? } if @input_clients
    end
    
    #
    # Called when a button is released and a game state active
    #
    def button_up(id)
      dispatch_button_up(id, self)
      @input_clients.each { |object| dispatch_button_up(id, object) unless object.paused? }   if @input_clients
    end
        
    #
    # Calls update on each game object that has current game state as parent (created inside that game state)
    #
    def update
      dispatch_input_for(self)
      
      @input_clients.each { |game_object| dispatch_input_for(game_object) unless game_object.paused? }      
      
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
      $window.close # FIXME what if $window is nil?
    end
  end
end
