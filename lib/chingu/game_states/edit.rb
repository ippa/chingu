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
  module GameStates
  
    #
    # Premade game state for chingu - A simple pause state.
    # Pause whenever with: 
    #   push_game_state(Chingu::GameStates::Pause)
    #
    # requires the global $window set to the instance of Gosu::Window (automaticly handled if you use Chingu::Window)
    #
    class Edit < Chingu::GameState
      def initialize(options = {})
        super
        @color = Gosu::Color.new(200,0,0,0)
        @red = Gosu::Color.new(0xFFFF0000)
        @white = Gosu::Color.new(0xFFFFFFFF)
        @selected_game_object = nil        
        self.input =  { :left_mouse_button => :left_mouse_button, 
                        :released_left_mouse_button => :released_left_mouse_button,
                        :e => :save_and_quit,
                        :s => :save,
                        :esc => :quit 
          }
      end

      def setup
        name = if defined?(previous_game_state.filename)
          previous_game_state.filename
        else 
          "#{previous_game_state.class.to_s.downcase}.yml"
        end
        @filename = File.join($window.root, name)
        @title = Text.create("Editing #{@filename}", :x => 5, :y => 10)
        @title2 = Text.create("(S) Save  (E) Save and Quit  (ESC) Quit without saving", :x => 5, :y => 30)
        @text = Text.create("", :x => 5, :y => 50)
      end
      
      def draw
        previous_game_state.draw    # Draw prev game state onto screen (in this case our level)
        
        $window.draw_quad(  0,0,@color,
                            $window.width,0,@color,
                            $window.width,100,@color,
                            0,100,@color,10)
        super
        
        previous_game_state.game_objects.select { |o| o.options[:selected] }.each do |game_object|
          
        #  rect = game_object.bounding_box
        #  rect.x *= $window.factor
        #  rect.y *= $window.factor
        #  $window.fill_rect(rect, @red, game_object.zorder - 1)
        end
        
        #
        # draw a simple triagle-shaped cursor
        #
        $window.draw_triangle( $window.mouse_x, $window.mouse_y, @white, 
                               $window.mouse_x, $window.mouse_y + 10, @white, 
                               $window.mouse_x + 10, $window.mouse_y + 10, @white, 9999)
                               
        if @left_mouse_button && @selected_game_object
          @selected_game_object.x = $window.mouse_x / $window.factor
          @selected_game_object.y = $window.mouse_y / $window.factor
          
          #
          # Can we abstract this out somehow?
          #
          if @selected_game_object.respond_to?(:bounding_box)
            @selected_game_object.bounding_box.x = @selected_game_object.x
            @selected_game_object.bounding_box.y = @selected_game_object.y
          end
        end
      end  
       
      def left_mouse_button
        @left_mouse_button = true
        x = $window.mouse_x / $window.factor
        y = $window.mouse_y / $window.factor
        @text.text = "Click @ #{x} / #{y}"
        @selected_game_object = game_object_at(x, y)
        if @selected_game_object
          @text.text = "#{@text.text} : #{@game_object.class.to_s}"
          @selected_game_object.options[:selected] = true
        end
      end
      
      def released_left_mouse_button
        @left_mouse_button = false
        @selected_game_object = false
      end
      
      def game_object_at(x, y)
        previous_game_state.game_objects.select do |game_object| 
          game_object.respond_to?(:bounding_box) && game_object.bounding_box.collide_point?(x,y)
        end.first
      end
      
      
      def save
        require 'yaml'
        objects = []
        previous_game_state.game_objects.each do |game_object|
          objects << {game_object.class.to_s  => 
                        {
                        :x => game_object.x, 
                        :y => game_object.y,
                        :angle => game_object.angle,
                        :zorder => game_object.zorder,
                        :factor_x => game_object.factor_x,
                        :factor_y => game_object.factor_y,
                        :center_x => game_object.center_x,
                        :center_y => game_object.center_y,
                        }
                      }
        end
        
        #Marshal.dump(previous_game_state.game_objects, File.open(@filename, "w"))
        File.open(@filename, 'w') do |out|
          YAML.dump(objects, out)
        end
      end
      
      def save_and_quit
        save
        quit
      end
      
      def quit
        pop_game_state
      end
      
      #
      # If we're editing a game state with automaticly called special methods, 
      # the following takes care of those.
      #
      def method_missing(symbol, *args)
        previous_game_state.__send__(symbol, *args)
      end
      
    end
  end
end
