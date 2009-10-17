module Chingu
  #
  # BasicGameObject. Resonating with 1.9.1, this is our most basic class that all game objects ultimate should build on.
  #
  # All objects that inherits from this class will by default be automaticly be updated and drawn.
  # It will also acts as a container for the trait-system of chingu.
  #
  class BasicGameObject
    attr_reader :options, :paused, :visible
    attr_accessor :parent
        
    #
    # adds a trait or traits to a certain game class
    # 
    # Executes a ruby "include" the specified module
    #
    def self.has_trait(*traits)
      has_traits(*traits)
    end
    
    #
    # See #has_trait
    #
    def self.has_traits(*traits)
      Array(traits).each do |trait|
        if trait.is_a?(::Symbol) || trait.is_a?(::String)
          include Chingu::Traits.const_get(Chingu::Inflector.camelize(trait))
        end
      end
    end
        
    #
    # BasicGameObject initialize
    # - call .setup_trait() on all traits that implements it
    #
    def initialize(options = {})
      @options = options
      
      #
      # A GameObject either belong to a GameState or our mainwindow ($window)
      #
      if $window && $window.respond_to?(:game_state_manager)
        @parent = $window.game_state_manager.inside_state || $window
      end
      
      # if true, BasicGameObject#update will be called
      @paused = options[:paused] || false
      
      # if true, BasicGameObject#draw will be called
      @visible = options[:visible] || true

      # This will call #setup_trait on the latest trait mixed in
      # which then will pass it on to the next setup_trait() with a super-call.
      setup_trait(options)
    end
    
    #
    # Creates a new object from class just as new() but also:
    # - adds game object to current game state
    # - or $window if no game state exists
    #
    # Use create() instead of new() if you want to keep track of your objects through
    # Chingus "game_objects" which is available in all game states and the main window.
    #
    def self.create(options = {})
      instance = self.new(options)
      
      
      #
      # Add to parents list of game objects
      #
      instance.parent.add_game_object(instance) if instance.parent
      
      return instance
    end

    #
    # Disable automatic calling of update() and update_trait() each game loop
    #
    def pause!
      @paused = true
    end
        
    #
    # Enable automatic calling of update() and update_trait() each game loop
    #
    def unpause!
      @paused = false
    end
    
    #
    # Disable automatic calling of draw and draw_trait each game loop
    #
    def hide!
      @visible = false
    end
    
    #
    # Enable automatic calling of draw and draw_trait each game loop
    #
    def show!
      @visible = true
    end

    #
    # Returns true if paused
    #
    def paused?
      @paused == true
    end

    #
    # Returns true if visible (not hidden)
    #
    def visible?
      @visible == true
    end

    def setup_trait(options)
    end
    
    def update_trait
		end
    
    def draw_trait
    end    
        
    def update
    end

    def draw
    end
    
        
    #
    # Returns an array with all objects of current class.
    # BasicGameObject#all is state aware so only objects belonging to the current state will be returned.
    #
    #   Bullet.all.each do {}  # Iterate through all bullets in current game state
    #
    def self.all
      $window.current_parent.game_objects.of_class(self).dup
    end
    
    #
    # Returns
    #
    def self.size
      $window.current_parent.game_objects.of_class(self).size
    end
    
    #
    # Destroy all instances of current class that fills a certain condition
    #   Enemy.destroy_if(&:dead?)   # Assumes Enemy.dead? returns true/false depending on aliveness :)
    #
    def self.destroy_if(&block)
      all.each do |object|
        object.destroy if yield(object)
      end
    end
    
    #
    # Destroys all intances of objects class:
    #   Bullet.destroy_all    # Removes all Bullet objects from the game
    #
    def self.destroy_all
      self.all.each { |object| object.destroy! }
    end

    #
    # Removes object from the update cycle and freezes the object to prevent further modifications.
    # If the object isn't being managed by Chingu (ie. you're doing manual update/draw calls) the object is only frozen, not removed from any updae cycle (because you are controlling that).
    #
    def destroy
      @parent.remove_game_object(self) if @parent
    end
    alias :destroy! :destroy
  end
end