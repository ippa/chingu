module Chingu
  #
  # BasicGameObject. Resonating with 1.9.1, this is our most basic class that all game objects ultimate should build on.
  #
  # All objects that inherits from this class will by default be automaticly be updated and drawn.
  # It will also acts as a container for the component-system of chingu.
  #
  class BasicGameObject
    attr_reader :options, :parent
    
    #
    # Create class variable @components in every new class derived from GameObject
    #
    def self.inherited(subclass)
      subclass.instance_variable_set("@components", Set.new)
    end
   
    class << self
      attr_accessor :components
    end
    
    #
    # adds a component to a certain game class
    # 
    # Executes a ruby "include" the specified module
    # and sets up update and draw hooks.
    #
    def self.add_component(*components)
      Array(components).each do |component|
        
        if component.is_a?(::Symbol) || component.is_a?(::String)
          string = "Chingu::Components::#{component.to_s.downcase.capitalize}"
          klass_or_module = eval(string)
          
          if klass_or_module.is_a?(Class)
            component = klass_or_module.new(self, {})
            @components << component
          elsif klass_or_module.is_a?(Module)
            include klass_or_module
          end
        end
      end
    end

    
    def initialize(options = {})
      @options = options
      setupable_components
      updateable_components
      drawable_components
      
      @setupable_components.each { |c| c.setup(self, options) }
      
      #
      # A GameObject can either belong to a GameState or our mainwindow ($window)
      # .. or live in limbo with manual updates
      #
      if $window && $window.respond_to?(:game_state_manager)
        @parent = $window.game_state_manager.inside_state || $window
        @parent.add_game_object(self) if @parent
      end
      
    end
    
    # Get all components added to the instance class
    def components; self.class.components || [];  end
    
    def setupable_components
      @setupable_components ||= components.select { |c| c.respond_to?(:setup) }
    end
    def updateable_components
      @updateable_components ||= components.select { |c| c.respond_to?(:update) }
    end
    def drawable_components
      @drawable_components ||= components.select { |c| c.respond_to?(:draw) }
    end
    
    #
    # Call .update on all components that implements it
    #
    def update
      @updateable_components.each { |c| c.update(self) }
		end
    
    #
    # Call .draw on all components that implements it
    #    
    def draw
      @drawable_components.each { |c| c.draw(self) }
    end
    
        
    #
    # Fetch all objects of a current class.
    #   Bullet.all   # => Enumerator of all objects of class Bullet
    #
    def self.all
      ObjectSpace.each_object(self)
    end
    
    #
    # Destroy all instances of current class that fills a certain condition
    #
    def self.destroy_if(&block)
      all.each do |object|
        object.destroy! if yield(object)
      end
    end
    
    #
    # Clear all intances of objects class
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