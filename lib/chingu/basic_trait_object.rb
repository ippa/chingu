module Chingu
  #
  # BasicGameObject. Resonating with 1.9.1, this is our most basic class that all game objects ultimate should build on.
  #
  # All objects that inherits from this class will by default be automaticly be updated and drawn.
  # It will also acts as a container for the trait-system of chingu.
  #
  class BasicTraitObject
    attr_reader :options, :parent
    
    #
    # Create class variable @traits in every new class derived from GameObject
    #
    def self.inherited(subclass)
      subclass.instance_variable_set("@traits", Set.new)
    end
   
    class << self
      attr_accessor :traits
    end
    
    #
    # adds a trait or traits to a certain game class
    # 
    # Executes a ruby "include" the specified module
    # and sets up update and draw hooks.
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
          string = "Chingu::Traits::#{Chingu::Inflector.camelize(trait)}"
          klass_or_module = Chingu::Traits.const_get(Chingu::Inflector.camelize(trait))
          
          if klass_or_module.is_a?(Class)
            trait = klass_or_module.new(self, {})
            @traits << trait
          elsif klass_or_module.is_a?(Module)
            include klass_or_module
          end
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
      
      setup(options)
    end
        
    def setup(options)
      puts "BasicTraitObject#setup"
      #super if respond_to?('super')
    end
    
    #
    # Call .update on all traits that implements it
    #
    def update
      puts "BasicTraitObject#update"
      #super if respond_to?('super')
		end
    
    #
    # Call .draw on all traits that implements it
    #    
    def draw
      puts "BasicTraitObject#draw"
      #super if respond_to?('super')
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