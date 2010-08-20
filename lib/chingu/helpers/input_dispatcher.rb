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

    # Called by input_clients to add themselves from forwarding.
    def add_input_client(object)
      @input_clients << object    unless @input_clients.include?(object)
    end

    # Called by input_clients to remove themselves from forwarding.
    def remove_input_client(object)
      @input_clients.delete(object)
    end

    # Dispatch button press to one of your clients.
    def dispatch_button_down(id, object)
      return unless Input::CONSTANT_TO_SYMBOL[id]
      if actions = object.input[Input::CONSTANT_TO_SYMBOL[id].first]
        dispatch_actions(actions)
      end
    end

    # Dispatch button release to one of your clients.
    def dispatch_button_up(id, object)
      return unless Input::CONSTANT_TO_SYMBOL[id]
      if actions = object.input[:"released_#{Input::CONSTANT_TO_SYMBOL[id].first}"]
        dispatch_actions(actions)
      end
    end

    #
    # Dispatches input-mapper for any given object
    #
    def dispatch_input_for(object, prefix = "holding_")
      pattern = /^#{prefix}/
      object.input.each do |symbol, actions|
        if symbol =~ pattern and $window.button_down?(Input::SYMBOL_TO_CONSTANT[$'.to_sym])
          dispatch_actions(actions)
        end
      end
    end

    #
    # For a given object, dispatch "action".
    # An action can be an array containing any of:
    #
    # * Proc/Lambda or Method, call() it
    # * GameState-instance, push it on top of stack
    # * GameState-inherited class, create a new instance, cache it and push it on top of stack
    #
    protected
    def dispatch_actions(actions)
      # puts "Dispatch Action: #{action} - Objects class: #{object.class.to_s}"
      actions.each do |action|
        case action
          when Proc, Method
            action[]
          when Chingu::GameState, Class
            # Don't need to check if the Class is a GameState, since that is already checked.
            push_game_state(action)
          else
            raise ArgumentError, "Unexpected action #{action}"
        end
      end
      # Other types will already have been resolved to one of these, so no need for checking.
    end
  end

  end
end