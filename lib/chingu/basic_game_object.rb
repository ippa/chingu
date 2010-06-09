require_rel 'helpers/class_inheritable_accessor'
module Chingu
  #
  # BasicGameObject. Resonating with 1.9.1, this is our most basic class that all game objects ultimate should build on.
  #
  # All objects that inherits from this class will by default be automaticly be updated and drawn.
  # It will also acts as a container for the trait-system of chingu.
  #
  class BasicGameObject
    include Chingu::Helpers::ClassInheritableAccessor # adds classmethod class_inheritable_accessor
    
    attr_reader :options, :paused, :visible
    attr_accessor :parent
    
    class_inheritable_accessor :trait_options
    @trait_options = Hash.new
    def trait_options; self.class.trait_options; end
            
    #
    # Adds a trait or traits to a certain game class
    # Executes a standard ruby "include" the specified module
    #
    def self.trait(trait, options = {})
      
      if trait.is_a?(::Symbol) || trait.is_a?(::String)
        ## puts "has_trait #{trait}, #{options}"
        begin
          # Convert user-given symbol (eg. :timer) to a Module (eg. Chingu::Traits::Timer)
          mod = Chingu::Traits.const_get(Chingu::Inflector.camelize(trait))
          
          # Include the module, which will add the containing methods as instance methods
          include mod
                   
          # Does sub-module "ClessMethods" exists?
          # (eg: Chingu::Traits::Timer::ClassMethods)
          if mod.const_defined?("ClassMethods")
            # Add methods in scope ClassMethods as.. class methods!
            mod2 = mod.const_get("ClassMethods")
            extend mod2
          
            # If the newly included trait has a initialize_trait method in the ClassMethods-scope:
            # ... call it with the options provided with the has_trait-line.
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
      Array(traits).each { |trait| has_trait trait }
    end
    class << self; alias :has_traits :traits; end
		
		#def self.inherited(subclass)
		#	subclass.initialize_inherited_trait	if subclass.method_defined?(:initialize_inherited_trait)
		#end
			
        
    #
    # BasicGameObject initialize
    # - call .setup_trait() on all traits that implements it
    #
    def initialize(options = {})
      @options = options
      @parent = options[:parent]
      
      #
      # A GameObject either belong to a GameState or our mainwindow ($window)
      #
      #if !@parent && $window && $window.respond_to?(:game_state_manager)
      #  @parent = $window.game_state_manager.inside_state || $window
      #end
      @parent = $window.current_scope if !@parent && $window
      
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
    #def self.create(options = {})
    def self.create(*options, &block)
      instance = self.new(*options, &block)
      
      #
      # Add to parents list of game objects
      #
      instance.parent.add_game_object(instance) if instance.parent
      
      
      return instance
    end

    #
    # This ruby callback is called each time someone subclasses BasicGameObject or GameObject
    # We hook into it to keep track of all game object classes (just as we keep track of game objects instances)
    #
    ## def self.inherited(klass)
    ##   instance.parent.add_game_object_class(klass) if instance.parent
    ## end

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

    #
    # Empty placeholders to be overridden
    #
    def self.initialize_trait(options); end
    def setup_trait(options); end
    def setup; end
    def update_trait; end
    def draw_trait; end    
    def update; end
    def draw; end
    
        
    #
    # Returns an array with all objects of current class.
    # BasicGameObject#all is state aware so only objects belonging to the current state will be returned.
    #
    #   Bullet.all.each do {}  # Iterate through all bullets in current game state
    #
    def self.all
      $window.current_scope.game_objects.of_class(self).dup
    end
    
    #
    # Returns
    #
    def self.size
      $window.current_scope.game_objects.of_class(self).size
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