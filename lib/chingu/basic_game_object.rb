require_rel 'helpers/class_inheritable_accessor'
require_rel 'inflector'

module Chingu
  #
  # BasicGameObject. Resonating with 1.9.1, this is our most basic class that all game objects ultimate should build on.
  #
  # All objects that inherits from this class will by default be automaticly be updated and drawn.
  # It will also acts as a container for the trait-system of chingu.
  #
  class BasicGameObject
    class << self; attr_accessor :instances; end
    
    include Chingu::Helpers::ClassInheritableAccessor # adds classmethod class_inheritable_accessor
    
    attr_reader :options, :paused
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
            # ... call it with the options provided with the trait-line.
            if mod2.method_defined?(:initialize_trait)
              initialize_trait(options)
            end
          end
        rescue
          puts "Error in 'trait #{trait}': " + $!.to_s
        end
      end
    end
    class << self; alias :has_trait :trait;  end
    
    def self.traits(*traits)
      Array(traits).each { |trait_name| trait trait_name }
    end
    class << self; alias :has_traits :traits; end
					
    alias :game_state :parent
    alias :game_state= :parent=
    
    #
    # BasicGameObject initialize
    # - call .setup_trait() on all traits that implements it
    #
    def initialize(options = {})
      @options = options
      @parent = options[:parent]
       
      self.class.instances ||= Array.new
      self.class.instances << self

      #
      # A GameObject either belong to a GameState or our mainwindow ($window)
      #
      @parent = $window.current_scope if !@parent && $window
      
      # if true, BasicGameObject#update will be called
      @paused = options[:paused] || options[:pause] || false
      
      # This will call #setup_trait on the latest trait mixed in
      # which then will pass it on to the next setup_trait() with a super-call.
      setup_trait(options)
      
      setup
    end

    #
    # Works just as BasicGameObject#new with the addition that Chingu will keep track of the new object.
    # The object will be assigned to a game_objects list. If created within a game state it will be added to that_game_state.game_objects.
    # Otherwise it will be added to $window.game_objects list.
    # The naming is inspired from ActiveRecord#create which will persist the object in the database right away.
    #
    # Chingu will automatically call update() and draw() on stored game objects.
    # Often in a smaller game this is exaclty what you want. If not, use the normal new().
    #
    def self.create(*options, &block)
      instance = self.new(*options, &block)
      
      #
      # Add to parents list of game objects
      #
      instance.parent.add_game_object(instance) if instance.parent
      
      #
      # Keep track of instances in class-variable
      # Used for quick access to all isntances of a certain class, for example Enemy.all
      #
      #instances ||= Array.new
      #instances << instance
      
      return instance
    end
    
    #
    # Disable automatic calling of update() and update_trait() each game loop
    #
    def pause!
      @parent.game_objects.pause_game_object(self)    if @parent && !@paused
      @paused = true
    end
    alias :pause :pause!
        
    #
    # Enable automatic calling of update() and update_trait() each game loop
    #
    def unpause!
      @parent.game_objects.unpause_game_object(self)  if @parent && @paused
      @paused = false
    end
    alias :unpause :unpause!
    
    #
    # Returns true if paused
    #
    def paused?
      @paused == true
    end

    #
    # Disable automatic calling of draw and draw_trait each game loop
    #
    def hide!
      @parent.game_objects.hide_game_object(self) if @parent && visible?
      @visible = false
    end
    alias :hide :hide!
    
    #
    # Enable automatic calling of draw and draw_trait each game loop
    #
    def show!
      @parent.game_objects.show_game_object(self) if @parent && !visible?
      @visible = true
    end
    alias :show :show!
    
    #
    # Returns true if visible (not hidden)
    #
    def visible?
      @visible == true
    end        

    #
    # Returns a filename-friendly string from the current class-name
    #
    # "FireBall" -> "fire_ball"
    #
    def filename
      Chingu::Inflector.underscore(Chingu::Inflector.demodulize(self.class.to_s))
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
      instances ? instances.dup : []
      # instances ? instances.keys : []                         # for hash instance
      #  $window.current_scope.game_objects.of_class(self).dup  # old school way
    end    
    
    #
    # As Array.each on the instances of the current class
    #
    def self.each
      all.each { |object| yield object }
    end

    #
    # As Array.each_with_index on the instances of the current class
    #
    def self.each_with_index
      all.each_with_index { |object, index| yield object, index }
    end

    #
    # As Array.select but on the instances of current class
    #
    def self.select
      all.select { |object| yield object }
    end
    
    #
    # Returns the total amount of game objects based on this class
    #
    def self.size
      all.size
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
      all.each { |game_object| game_object.parent.remove_game_object(game_object) }
      instances.clear if  instances
    end

    #
    # Removes object from the update cycle and freezes the object to prevent further modifications.
    # If the object isn't being managed by Chingu (ie. you're doing manual update/draw calls) the object is only frozen, not removed from any updae cycle (because you are controlling that).
    #
    def destroy
      if @parent
        @parent.remove_game_object(self)
        @parent.remove_input_client(self)
      end
      self.class.instances.delete(self)
    end
    alias :destroy! :destroy
  end
end
