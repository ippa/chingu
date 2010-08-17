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
    # Input-handler mixin that adds #input= and #input
    # 
    # #input= does 2 things:
    # 1) Initialized an inputmap
    # 2) notifies the parent (could be main Window or a GameState) that the object wants input
    #
    # In Chingu this is mixed into Window, GameState and GameObject.
    #
    # You can specify input in 3 different natural formats, the bellow 3 lines does the same thing:
    #
    # The normal way, this makes left_arrow key call method "left", and the same thing for right.
    #   self.input = {:left => :left, :right => :right}
    #
    # The shortened way, does exaclty as the above.
    #   self.input = [:left, :right]
    #  
    # The multi-way, adds :a as trigger for method left, and :d as trigger for method :right
    #   self.input = {[:a, :left] => :left, [:right, :d] => :right}
    #
    #
    module InputClient
      # The current input handlers. This may contain data which is different to the input set,
      # but it will be equivalent in function [Hash].
      def input
        @input ||= Hash.new { |hash, key| hash[key] = [] }
      end

      # Is a particular key being held down at this moment?
      #
      # === Parameters
      # +key+:: Chingu key code [Symbol]
      #
      public
      def holding?(key)
        $window.button_down?(Chingu::Input::SYMBOL_TO_CONSTANT[key])
      end

      # Are any of a list of keys being held down?
      #
      # === Parameters
      # +key+:: Chingu key code [Symbol]
      #
      # :call-seq:
      #    holding_any?(key [, key]*) { } -> true or false
      #
      public
      def holding_any?(*keys)
        keys.any? { |key| holding?(key) }
      end

      # Are all keys in a list being held down simultaneously?
      #
      # === Parameters
      # +key+:: Chingu key code [Symbol]
      #
      # :call-seq:
      #   holding_all?(key [, key]*) { } -> true or false
      #
      public
      def holding_all?(*keys)
        keys.all? { |key| holding?(key) }
      end

      # Ensures that the key code exists and ensures it has a consistent name.
      #
      # === Parameters
      # +key+:: Chingu key code [Symbol]
      #
      # Returns: Key code [Symbol]
      #
      protected
      def validate_input_key(key)
        raise ArgumentError, "Input must be a Symbol or #{MultiInput}, but received #{key} (#{key.class})" unless key.is_a? Symbol

        # The base key is the key without a prefix, so we can find it in the lookups.
        base_key = Chingu::Input::SYMBOL_TO_CONSTANT.has_key?(key) ? key : nil
        prefix_used = ""
        ["holding_", "released_"].each do |prefix|
          break if base_key
          if key =~ /^#{prefix}(.*)$/
            base_key = Chingu::Input::SYMBOL_TO_CONSTANT.has_key?($1.to_sym) ? $1.to_sym : nil
            prefix_used = prefix
          end
        end

        raise ArgumentError, "No such input as #{key.inspect}" unless base_key

        # Standardise the symbol used.
        :"#{prefix_used}#{Input::CONSTANT_TO_SYMBOL[Input::SYMBOL_TO_CONSTANT[base_key]].first}"
      end

      # Ensures that the key code exists and ensures it has a consistent name.
      #
      # === Parameters
      # +key+:: Chingu key code [Symbol]
      # +action+:: Action to perform [Method/Proc/String/Symbol/Class/Chingu::GameState]
      #
      # Returns: Key code, action [Array]
      #
      protected
      def validate_input(key, action)
        key = validate_input_key(key)
        
        message = case action
          when Method, Proc, Chingu::GameState
            nil

          when String, Symbol
            "#{self.class} does not have a #{action} method" unless self.respond_to? action
            # Resolve to a method.
            action = method action
            
            nil

          when Class
            if action.ancestors.include? Chingu::GameState
              nil
            else
              "Input action is a class (#{action.class}) not inheriting from Chingu::GameState"
            end

          else
            "Input action must be a Method, Proc, String, Symbol, Chingu::GameState or a class inheriting from Chingu::GameState (Received a #{action.class})"
        end

        raise ArgumentError, "(For input #{key.inspect}) #{message}" if message

        [key, action]
      end

      # Add input handlers all at once. This is an alternative to on_input, which sets input handlers individually.
      #
      # === Parameters
      # +input_list+:: [Hash or Array]
      #
      # === Examples
      # As a hash (Will call move_left or move_right methods when keys pressed):
      #   add_inputs :left_arrow => :move_left,
      #             :right_arrow => :move_right
      #
      # As an array (Will call left_arrow or right_arrow methods when keys pressed):
      #   add_inputs :left_arrow, :right_arrow

      # :call-seq:
      #   add_inputs(input [, input]*] -> self
      #   add_inputs(input => action [, input => action]*) -> self
      #
      public
      def add_inputs(*input_list)
        raise "Need to provide inputs as either parameters or hashed parameters" if input_list.empty?
        input_list = input_list[0] if input_list[0].is_a? Hash

        case input_list
          when Array
            #
            # Un-nest input_map [:left, :right, :space]
            # Into: { :left => :left, :right => :right, :space => :space }
            #
            input_list.each { |symbol| on_input(symbol) }
            
          when Hash
            #
            # Un-nest input:  { [:pad_left, :arrow_left, :a] => :move_left }
            # Into:  { :pad_left => :move_left, :arrow_left => :move_left, :a => :move_left }
            #
            input_list.each_pair do |possible_array, action|
              case possible_array
                when Array
                  possible_array.each { |symbol| on_input(symbol, action) }
                when Symbol
                  on_input(possible_array, action)
              end
          end
        end

        self
      end

      # Backwards compatibility function. Use on_inputs or on_input instead.
      def input=(input_list)
        @input = nil
        input_list.is_a?(Array) ? on_inputs(*input_list) : on_inputs(input_list)
      end

      # Adds an event handler for a key or any of a list of keys. This is an alternative to input=, which sets all
      # handlers at once.
      #
      # === Parameters
      # +input+:: Chingu input code(s) [Symbol or Array of Symbols]
      # +action+:: [Method/Proc/String/Symbol/Class/Chingu::GameState]
      #
      # Returns: self
      #
      # === Examples
      # Using actions:
      #   on_input(:space) # Will call the space method when input detected.
      #   on_input(:space, :fire_laser)
      #   on_input([:left, :a], method(:go_left))
      #
      # Using blocks:
      #   on_input :space do
      #      # Fire the laser
      #   end
      #   on_input [:left, :a] do
      #      # Move the player left.
      #   end
      #
      # :call-seq:
      #    on_input(input)         -> self
      #    on_input(input) { }     -> self
      #    on_input(input, action) -> self
      #
      public
      def on_input(input, action = nil, &block)
        raise ArgumentError, "#{self.class}#on_input takes either an input OR an input and action OR an input with a block" if action and block

        inputs = input.is_a?(Array) ? input : [input]  # Can be a single input or an array of them.
        action = block if block
        action = input unless action

        @input ||= Hash.new { |hash, key| hash[key] = [] }

        # Ensure that the new input array is reasonable.
        inputs.each do |input|
          standardised_symbol, action = validate_input(input, action)
          @input[standardised_symbol] << action
        end

        if @parent
          if @input.empty?
            @parent.remove_input_client(self)
          else
            @parent.add_input_client(self)
          end
        end
        
        self
      end
    end
  end
end