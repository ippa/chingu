module Chingu
  
  module InputClient
    def input=(input_map)
      @input = input_map
      @parent.add_input_client(self)  if @parent
    end
    
    def input
      @input
    end
  end
    
  module InputDispatcher
    def add_input_client(object)
      @input_clients << object
    end
    
    def remove_input_client(object)
      @input_clients.delete(object)
    end

    def dispatch_button_down(id, object)
      return if(object.nil? || object.input.nil?)
      
      object.input.each do |symbol, action|
        if Input::SYMBOL_TO_CONSTANT[symbol] == id
          dispatch_action(action, object)
        end        
      end
    end
    
    def dispatch_button_up(id, object)
      return if object.nil? || object.input.nil?
      
      object.input.each do |symbol, action|
        if symbol.to_s.include? "released_"
          symbol = symbol.to_s.sub("released_", "").to_sym
          if Input::SYMBOL_TO_CONSTANT[symbol] == id
            dispatch_action(action, object)
          end
        end
      end
    end
    
    #
    # Dispatches input-mapper for any given object
    #
    def dispatch_input_for(object, prefix = "holding_")
      return if object.nil? || object.input.nil?
      
      object.input.each do |symbol, action|
        if symbol.to_s.include? prefix
          symbol = symbol.to_s.sub(prefix, "").to_sym
          if $window.button_down?(Input::SYMBOL_TO_CONSTANT[symbol])
            dispatch_action(action, object)
          end
        end
      end
    end
    
    #
    # For a given object, dispatch "action".
    # An action can be:
    #
    # * Symbol (:p, :space), translates into a method-call
    # * Proc/Lambda, call() it
    # * GameState-instance, push it on top of stack
    # * GameState-inherited class, create a new instance, cache it and push it on top of stack
    #
    def dispatch_action(action, object)
      # puts "Dispatch Action: #{action} - Objects class: #{object.class.to_s}"
      if action.is_a? Symbol
        object.send(action)
      elsif action.is_a? Proc
        action.call
      elsif action.is_a? Chingu::GameState
        push_game_state(action)
      elsif action.superclass == Chingu::GameState
        push_game_state(action)
      end
    end
  end

  #
  # push_game_state accepts either a class inherited from GameState or an object-instance from such a class.
  #
  # It will make call new() on a class, and just push an object.
  #
  module GameStateHelpers
    def push_game_state(state, options = {})
      $window.game_state_manager.push_game_state(state, options)      
    end
  
    def pop_game_state(options = {})
      $window.game_state_manager.pop_game_state(options)
    end

    def switch_game_state(state, options = {})
      $window.game_state_manager.switch_game_state(state, options)
    end

    def transitional_game_state(state, options = {})
      $window.game_state_manager.transitional_game_state(state, options)      
    end

    def current_game_state
      $window.game_state_manager.current_game_state
    end

    def previous_game_state
      $window.game_state_manager.previous_game_state
    end
    
    def clear_game_states
      $window.game_state_manager.clear_game_states
    end
  end
  
  module GameObjectHelpers
    #
    # Fetch game objects of a certain type/class
    #
    def game_objects_of_class(klass)
      @game_objects.select { |game_object| game_object.is_a? klass }
    end
  end

end