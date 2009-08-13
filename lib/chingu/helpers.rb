module Chingu
  
  module InputClient
    def input=(input_map)
      @input = input_map
      @parent.add_input_client(self)  if @parent
      #$window.add_input_client(self)
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
      dispatch_button(id, object, "pressed_")
    end
    
    def dispatch_button_up(id, object)
      dispatch_button(id, object, "released_")
    end
    
    #
    # Dispatch pressed and released buttons (Gosu's button_up() / button_down())
    #
    def dispatch_button(id, object, prefix = "pressed_")
      return if object.nil? || object.input.nil?
      
      object.input.each do |symbol, action|
        if symbol.to_s.include? prefix
          symbol = symbol.to_s.sub(prefix, "").to_sym
          if Input::SYMBOL_TO_CONSTANT[symbol] == id
            dispatch_action(action, object)
          end
        end
      end
    end
    
    #
    # Dispatches input-mapper for any given object
    #
    def dispatch_input_for(object)
      return if object.nil? || object.input.nil?
      
      object.input.each do |symbol, action|
        if $window.button_down?(Input::SYMBOL_TO_CONSTANT[symbol])
          dispatch_action(action, object)
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
  # push_game_state(Intro):
  # game state mananger will create a new Intro-object first time called and cache it.
  #
  # push_game_state(Intro.new):
  # The first line ends up calling "new" to Intro before activating the newly created game state.
  # Each time 'push_game_state(Intro.new)' is called a new Intro-object will be created.
  # Usefull for stuff like: push_game_state(Level.new(:level_nr => 11))
  #
  module GameStateHelpers
    def push_game_state(state, options = {})
      $window.game_state_manager.push_state(state, options)      
    end
  
    def pop_game_state(options = {})
      $window.game_state_manager.pop_state(options)
    end

    def current_game_state
      $window.game_state_manager.current_state
    end

    def previous_game_state
      $window.game_state_manager.previous_state
    end

    def clear_game_states
      $window.game_state_manager.clear_states
    end
  end

  #
  # Various helper-methods to manipulate the screen
  #
  module DrawHelpers
    #
    # Fills whole window with color 'c'
    #
    def fill(c)
      $window.draw_quad(0,0,c,$window.width,0,c,$window.width,$window.width,c,0,$window.height,c,0,:default)
    end
     
    #
    # Fills a given Rect 'r' with color 'c'
    #
    def fill_rect(r, c)
      $window.draw_quad(r.x,r.y,c, r.right,r.y,c, r.right,r.bottom,c, r.x,r.bottom,c,0,:default)
    end
     
    def fade(options = {})
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