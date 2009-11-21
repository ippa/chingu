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
      def input=(input_map)
        @input ||= Hash.new
        #@input = input_map

        if input_map.is_a? Array
          #
          # Un-nest input_map [:left, :right, :space]
          # Into: { :left => :left, :right => :right, :space => :space}
          #
          input_map.each do |symbol|
            @input[symbol] = symbol
          end
        elsif input_map.is_a? Hash
          #
          # Un-nest input:  { [:pad_left, :arrow_left, :a] => :move_left }
          # Into:  { :pad_left => :move_left, :arrow_left => :move_left, :a => :move_left }
          #
          input_map.each_pair do |possible_array, action|
            if possible_array.is_a? Array
              possible_array.each do |symbol|
                @input[symbol] = action
              end
            elsif possible_array.is_a? Symbol
              @input[possible_array] = action
            end
          end
        end
        
        if @parent 
          if (@input == nil || @input == {})
            @parent.remove_input_client(self)
          else
            @parent.add_input_client(self)
          end
        end
      end
      
      def input
        @input
      end
    end
  end
end