module Chingu
  #
  # BasicGameObject. Resonating with 1.9.1, this is our most basic class that all game objects ultimate should build on.
  #
  # All objects that inherits from this class will by default be automaticly be updated and drawn.
  # It will also acts as a container for the trait-system of chingu.
  #
  class BasicGameObject
    attr_reader :options, :parent
    
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
    # BasicGameUnit initialize
    #
    # - caches all trait methods for fast calls later on
    # - call .setup() on all traits that implements it
    # - adds game object to correct game state or $window if no game state exists
    #
    def initialize(options = {})
      @options = options
      
      #
      # A GameObject can either belong to a GameState or our mainwindow ($window)
      # .. or live in limbo with manual updates
      #
      if $window && $window.respond_to?(:game_state_manager)
        @parent = $window.game_state_manager.inside_state || $window
        @parent.add_game_object(self) if @parent
      end
      
      # This will call #setup on the latest trait mixed in, which then will pass it on with super.
      setup_trait(options) 
    end
    

    def setup_trait(options)
    end
    
    def update
		end
    
    def draw
    end    
        
    #
    # Fetch all objects of a current class.
    #   Bullet.all   # => Enumerator of all objects of class Bullet
    #
    # NOTE: ObjectSpace doesn't play nice with jruby.
    #
    def self.all
      ObjectSpace.each_object(self)
    end
    
    #
    # Destroy all instances of current class that fills a certain condition
    #   Enemy.destroy_if(&:dead?)   # Assumes Enemy.dead? returns true/false depending on aliveness :)
    #
    #
    def self.destroy_if(&block)
      all.each do |object|
        object.destroy! if yield(object)
      end
    end
    
    #
    # Clear all intances of objects class:
    #   Bullet.clear    # Removes all Bullet objects from the game
    #
    def self.clear
      all.each { |object| object.destroy! }
    end

    #
    # Removes object from the update cycle and freezes the object to prevent further modifications.
    # If the object isn't being managed by Chingu (ie. you're doing manual update/draw calls) the object is only frozen, not removed from any updae cycle (because you are controlling that).
    #
    def destroy!
      @parent.remove_game_object(self) if @parent
      self.freeze
    end    
  end
end