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
    # Premade game state for chingu - simple level editing.
    # Start editing in a gamestate with:
    #   push_game_state(Chingu::GameStates::Edit)
    #
    # requires the global $window set to the instance of Gosu::Window (automaticly handled if you use Chingu::Window)
    #
    class Edit < Chingu::GameState
      
      def initialize(options = {})
        super
        @grid = options[:grid] || [8,8]
        @classes = options[:classes] || []
        @only = options[:only] || []
        @except = options[:except] || []
        @filename = options[:filename]
        
        unless @filename
          name = if defined?(previous_game_state.filename)
            previous_game_state.filename
          else 
            "#{previous_game_state.class.to_s.downcase}.yml"
          end
          @filename = File.join($window.root, name)
        end
        
        @color = Gosu::Color.new(200,0,0,0)
        @selected_game_object = nil        
        self.input =  { :left_mouse_button => :left_mouse_button, 
                        :released_left_mouse_button => :released_left_mouse_button,
                        :delete => :destroy_selected_game_objects,
                        :backspace => :destroy_selected_game_objects,
                        :e => :save_and_quit,
                        :s => :save,
                        :esc => :quit,
                        :holding_up_arrow => :scroll_up,
                        :holding_down_arrow => :scroll_down,
                        :holding_left_arrow => :scroll_left,
                        :holding_right_arrow => :scroll_right,
                        :page_up => :page_up,
                        :page_down => :page_down,
                        :"1" => :create_object_1,
                        :"2" => :create_object_2,
                        :"3" => :create_object_3,
                        :"4" => :create_object_4,
                        :"5" => :create_object_5,
                      }
        
        x = 32
        y = 70
        @classes.each do |klass|
          puts "Creating a #{klass}"
          if game_object = klass.create(:save_to_file => false)
            game_object.x = x + game_object.image.width
            game_object.y = y + game_object.image.height
            x += 32
          end
        end
      end
      
      def game_object_classes
        ObjectSpace.enum_for(:each_object, class << GameObject; self; end).to_a.select do |game_class|
          game_class.instance_methods
        end
      end
      
      def page_up
        self.previous_game_state.viewport.y -= $window.height if defined?(self.previous_game_state.viewport)
      end
      def page_down
        self.previous_game_state.viewport.y += $window.height if defined?(self.previous_game_state.viewport)
      end
      def scroll_up
        self.previous_game_state.viewport.y -= 10 if defined?(self.previous_game_state.viewport)
      end
      def scroll_down
        self.previous_game_state.viewport.y += 10 if defined?(self.previous_game_state.viewport)
      end
      def scroll_left
        self.previous_game_state.viewport.x -= 10 if defined?(self.previous_game_state.viewport)
      end
      def scroll_right
        self.previous_game_state.viewport.x += 10 if defined?(self.previous_game_state.viewport)
      end
      
      def x
        x = $window.mouse_x 
        x += self.previous_game_state.viewport.x if defined?(self.previous_game_state.viewport)
      end

      def y
        y = $window.mouse_y
        y += self.previous_game_state.viewport.y if defined?(self.previous_game_state.viewport)
      end

      def setup
        Text.font = "arial"
        Text.size = 15
                
        @title = Text.create("#{@filename}", :x => 5, :y => 2, :factor => 1)
        @title.text += " - Grid: #{@grid}" if @grid
        #@title2 = Text.create("(1-10) Create object at mouse pos  (DEL) Delete selected object  (S) Save  (E) Save and Quit  (ESC) Quit without saving", :x => 5, :y => 30, :factor => 1)
        @text = Text.create("", :x => 5, :y => 50, :factor => 1)
        
        @status_text = Text.create("-", :x => 5, :y => $window.height-20, :factor => 1)
      end
      
      def create_object_nr(number)
        c = @classes[number].create(:x => x, :y => y, :parent => previous_game_state)  if @classes[number]
        @text.text = "Created a #{c.class} @ #{c.x} / #{c.y}"
      end
      
      def create_object_1; create_object_nr(0); end
      def create_object_2; create_object_nr(1); end
      def create_object_3; create_object_nr(2); end
      def create_object_4; create_object_nr(3); end
      def create_object_5; create_object_nr(4); end
      
      def draw
        # Draw prev game state onto screen (the level we're editing)
        previous_game_state.draw 
        
        #
        # Draw an edit HUD
        #
        $window.draw_quad(  0,0,@color,
                            $window.width,0,@color,
                            $window.width,20,@color,
                            0,20,@color,10)

        #
        # Draw an status HUD
        #
        $window.draw_quad(  0,$window.height - 30,@color,
                            $window.width,$window.height - 30,@color,
                            $window.width,$window.height,@color,
                            0,$window.height,@color,10)

        #
        # Draw debug Texts etc..
        #
        super
        
        #
        # Draw a red rectangle around all selected game objects
        #
        selected_game_objects.each do |game_object|
          draw_rect(game_object.bounding_box.inflate(2,2), Color::RED, 999)
        end
        
        #
        # draw a simple triagle-shaped cursor
        #
        $window.draw_triangle( $window.mouse_x, $window.mouse_y, Color::WHITE, 
                               $window.mouse_x, $window.mouse_y + 10, Color::WHITE, 
                               $window.mouse_x + 10, $window.mouse_y + 10, Color::WHITE, 9999)
        
      end
      
      def update
        super
        
        if @left_mouse_button && @selected_game_object
          @selected_game_object.x = x + @mouse_x_offset
          @selected_game_object.y = y + @mouse_y_offset
          
          @selected_game_object.x -= @selected_game_object.x % @grid[0]
          @selected_game_object.y -= @selected_game_object.y % @grid[1]
          
          # TODO: better cleaner sollution
          if @selected_game_object.respond_to?(:bounding_box)
            @selected_game_object.bounding_box.x = @selected_game_object.x
            @selected_game_object.bounding_box.y = @selected_game_object.y
          end
        end
        
        @status_text.text = "#{x} / #{y}"
      end

      def selected_game_objects
        previous_game_state.game_objects.select { |o| o.options[:selected] }
      end
      
      def destroy_selected_game_objects
        selected_game_objects.each(&:destroy)
      end
       
      def left_mouse_button
        @left_mouse_button = true        
        
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
        
        @text.text = game_object_icon_at($window.mouse_x, $window.mouse_y).class
        
        if @selected_game_object
          @text.text = "#{@text.text} : #{@selected_game_object.class.to_s}"
          @selected_game_object.options[:selected] = true
          
          @mouse_x_offset = @selected_game_object.x - x
          @mouse_y_offset = @selected_game_object.y - y          
        end
        
      end
      
      def released_left_mouse_button        
        @left_mouse_button = false
        @selected_game_object = false
      end

      def game_object_icon_at(x, y)
        game_objects.select do |game_object| 
          game_object.respond_to?(:bounding_box) && game_object.bounding_box.collide_point?(x,y)
        end.first
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
