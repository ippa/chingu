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
        @grid = options[:grid]
        @classes = options[:classes] || []
        
        @color = Gosu::Color.new(200,0,0,0)
        @red = Gosu::Color.new(0xFFFF0000)
        @white = Gosu::Color.new(0xFFFFFFFF)
        @selected_game_object = nil        
        self.input =  { :left_mouse_button => :left_mouse_button, 
                        :released_left_mouse_button => :released_left_mouse_button,
                        :delete => :destroy_selected_game_objects,
                        :e => :save_and_quit,
                        :s => :save,
                        :esc => :quit,
                        :"1" => :create_object_1,
                        :"2" => :create_object_2,
                        :"3" => :create_object_3,
                        :"4" => :create_object_4,
                        :"5" => :create_object_5,
                      }
      end

      def setup
        name = if defined?(previous_game_state.filename)
          previous_game_state.filename
        else 
          "#{previous_game_state.class.to_s.downcase}.yml"
        end
        @filename = File.join($window.root, name)
        @title = Text.create("File: #{@filename}", :x => 5, :y => 10)
        @title.text += " - Grid: #{@grid}" if @grid
        @title2 = Text.create("(1-10) Create object at mouse pos  (DEL) Delete selected object  (S) Save  (E) Save and Quit  (ESC) Quit without saving", :x => 5, :y => 30)        
        @text = Text.create("", :x => 5, :y => 50)        
      end
      
      def create_object_nr(number)
        @classes[number].create(:x => $window.mouse_x, :y => $window.mouse_y, :parent => previous_game_state)  if @classes[number]
      end
      
      def create_object_1; create_object_nr(0); end
      def create_object_2; create_object_nr(1); end
      def create_object_3; create_object_nr(2); end
      def create_object_4; create_object_nr(3); end
      def create_object_5; create_object_nr(4); end
      
        
      
      def draw
        # Draw prev game state onto screen (the level we're editing for example)
        previous_game_state.draw 
        
        #
        # Draw an edit HUD
        #
        $window.draw_quad(  0,0,@color,
                            $window.width,0,@color,
                            $window.width,100,@color,
                            0,100,@color,10)
        #
        # Draw debug Texts etc..
        #
        super
        
        #
        # Draw a red rectangle around all selected game objects
        #
        selected_game_objects.each do |game_object|
          draw_rect(game_object.bounding_box.inflate(2,2), @red, 999)
        end
        
        #
        # draw a simple triagle-shaped cursor
        #
        $window.draw_triangle( $window.mouse_x, $window.mouse_y, @white, 
                               $window.mouse_x, $window.mouse_y + 10, @white, 
                               $window.mouse_x + 10, $window.mouse_y + 10, @white, 9999)
        
      end
      
      def update
        super
        
        if @left_mouse_button && @selected_game_object
          @selected_game_object.x = ($window.mouse_x + @mouse_x_offset) / $window.factor
          @selected_game_object.y = ($window.mouse_y + @mouse_y_offset) / $window.factor
          @selected_game_object.x -= @selected_game_object.x % @grid[0]
          @selected_game_object.y -= @selected_game_object.y % @grid[1]
          
          # TODO: better cleaner sollution
          if @selected_game_object.respond_to?(:bounding_box)
            @selected_game_object.bounding_box.x = @selected_game_object.x
            @selected_game_object.bounding_box.y = @selected_game_object.y
          end
        end
      end

      def selected_game_objects
        previous_game_state.game_objects.select { |o| o.options[:selected] }
      end
      
      def destroy_selected_game_objects
        selected_game_objects.each(&:destroy)
      end
       
      def left_mouse_button
        @left_mouse_button = true
        x = $window.mouse_x / $window.factor
        y = $window.mouse_y / $window.factor
                
        @text.text = "Click @ #{x} / #{y}"
        
        #
        # Deselect all objects
        #
        selected_game_objects.each do |game_object|         
          game_object.options[:selected] = false
        end
        
        #
        # Get new object that was clicked at (if any)
        #
        @selected_game_object = game_object_at(x, y)
        
        if @selected_game_object
          @text.text = "#{@text.text} : #{@selected_game_object.class.to_s}"
          @selected_game_object.options[:selected] = true
          
          @mouse_x_offset = @selected_game_object.x - $window.mouse_x
          @mouse_y_offset = @selected_game_object.y - $window.mouse_y
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
        pop_game_state(:setup => false)
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
