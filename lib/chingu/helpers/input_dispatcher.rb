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
  module Helpers
  
  #
  # Methods for parsing and dispatching Chingus input-maps
  # Mixed into Chingu::Window and Chingu::GameState
  #
  module InputDispatcher
    attr_reader :input_clients
    
    def add_input_client(object)
      @input_clients << object    unless @input_clients.include?(object)
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
    # * Symbol (:p, :space) or String, translates into a method-call
    # * Proc/Lambda or Method, call() it
    # * GameState-instance, push it on top of stack
    # * GameState-inherited class, create a new instance, cache it and push it on top of stack
    #
    def dispatch_action(action, object)
      #puts "Dispatch Action: #{action} - Objects class: #{object.class.to_s}"
      
      case action
      when Symbol, String
        object.send(action)
      when Proc, Method
        action[]
      when Chingu::GameState
        push_game_state(action)
      when Class
        if action.ancestors.include?(Chingu::GameState)
          push_game_state(action)
        end
      else
        # TODO possibly raise an error? This ought to be handled when the input is specified in the first place.
      end
    end
  end
  
  end
end