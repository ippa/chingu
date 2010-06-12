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
        @file = options[:file]
        @zorder = 10000
        
        @hud_color = Gosu::Color.new(150,100,100,100)
        @selected_game_object = nil        
        self.input =  { :left_mouse_button => :left_mouse_button, 
                        :released_left_mouse_button => :released_left_mouse_button,
                        :delete => :destroy_selected_game_objects,
                        :backspace => :destroy_selected_game_objects,
                        :e => :save_and_quit,
                        :s => :save,
                        :esc => :save_and_quit,
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
        
        x = 10
        y = 50
        @classes.each do |klass|
          puts "Creating a #{klass}"
          game_object = klass.create(:x => x, :y => y, :zorder => @zorder)
          game_object.rotation_center = :top_left
          
          if game_object.image
            game_object.factor_x = 32 / game_object.image.width
            game_object.factor_y = 32 / game_object.image.height
          end
          x += 32
        end
        # @save = Text.create("SAVE", :x => $window.width - 150, :size => 16)
        
      end
      
      def setup
        # Disable input for previous game state (restore on exit)
        #saved_input_map = previous_game_state.input
        #previous_game_state.input = {}
      end
      
      def finalize
        #previous_game_state.input = saved_input_map
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
        unless @file
          name = if defined?(previous_game_state.filename)
            previous_game_state.filename
          else 
            "#{previous_game_state.class.to_s.downcase}.yml"
          end
          @file = File.join($window.root, name)
        end
        
        Text.font = "arial"
        Text.size = 15
                
        @title = Text.create("File: #{@file}", :x => 5, :y => 2, :factor => 1, :size => 16, :zorder => @zorder)
        @title.text += " - Grid: #{@grid}" if @grid
        
        #@title2 = Text.create("(1-10) Create object at mouse pos  (DEL) Delete selected object  (S) Save  (E) Save and Quit  (ESC) Quit without saving", :x => 5, :y => 30, :factor => 1)
        
        @text = Text.create("", :x => 200, :y => 20, :factor => 1, :size => 16, :zorder => @zorder)
        @status_text = Text.create("-", :x => 5, :y => 20, :factor => 1, :size => 16, :zorder => @zorder)
      end
      
      def create_object_nr(number)
        c = @classes[number].create(:x => x, :y => y, :parent => previous_game_state)  if @classes[number]
        #@text.text = "Created a #{c.class} @ #{c.x} / #{c.y}"
      end
      
      def create_object_1; create_object_nr(0); end
      def create_object_2; create_object_nr(1); end
      def create_object_3; create_object_nr(2); end
      def create_object_4; create_object_nr(3); end
      def create_object_5; create_object_nr(4); end
      
      def draw
        # Draw prev game state onto screen (the level we're editing)
        previous_game_state.draw
        
        super
        
        #
        # Draw an edit HUD
        #
        $window.draw_quad(  0,0,@hud_color,
                            $window.width,0,@hud_color,
                            $window.width,100,@hud_color,
                            0,100,@hud_color, @zorder-1)
        
        #
        # Draw red rectangles/circles around all selected game objects
        #
        selected_game_objects.each { |game_object| game_object.draw_debug }
        
        if @cursor_game_object
          @cursor_game_object.draw_at($window.mouse_x, $window.mouse_y)
        else
          #
          # draw a simple triagle-shaped cursor
          #
          $window.draw_triangle( $window.mouse_x, $window.mouse_y, Color::WHITE, 
                                $window.mouse_x, $window.mouse_y + 10, Color::WHITE, 
                                $window.mouse_x + 10, $window.mouse_y + 10, Color::WHITE, @zorder + 10)
        end
      end
      
      def update
        # previous_game_state.update
        
        # Hacky way of preventing game objects to move
        # While you edit you don't want enemies running around etc etc..
        # TODO: Solve this in a more general way? Skip call to previous_game_state.update in whole maybe.
        previous_game_state.game_objects.each do |game_object|
          game_object.x = game_object.previous_x if defined?(game_object.previous_x)
          game_object.y = game_object.previous_y if defined?(game_object.previous_y)
        end
        
        super
        
        if @left_mouse_button && @selected_game_object
          @text.text = "#{@selected_game_object.class.to_s} @ #{@selected_game_object.x} / #{@selected_game_object.y}"
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
        
        @status_text.text = "Mouseposition: #{x} / #{y}"
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

        if @cursor_game_object && game_object_at(x, y)==nil && game_object_icon_at($window.mouse_x, $window.mouse_y) == nil
          game_object = @cursor_game_object.class.create(:x => x, :y => y, :parent => previous_game_state, :zorder => @zorder + 10)
          game_object.options[:selected] = true
        end
        
        #
        # Get new object that was clicked at (if any)
        #
        @selected_game_object = game_object_at(x, y)
        
        @cursor_game_object = game_object_icon_at($window.mouse_x, $window.mouse_y)
              
        if @selected_game_object
          @selected_game_object.options[:selected] = true
          
          @mouse_x_offset = @selected_game_object.x - x
          @mouse_y_offset = @selected_game_object.y - y          
        else
          @text.text = ""
        end
        
      end
      
      def released_left_mouse_button        
        @left_mouse_button = false
        @selected_game_object = false
      end

      def game_object_icon_at(x, y)
        game_objects.select do |game_object| 
          game_object.respond_to?(:collision_at?) && game_object.collision_at?(x,y)
        end.first
      end

      def game_object_at(x, y)
        previous_game_state.game_objects.select do |game_object| 
          game_object.respond_to?(:collision_at?) && game_object.collision_at?(x,y)
        end.first
      end
      
      def save
        save_game_objects(:game_objects => previous_game_state.game_objects, :file => @file, :classes => @classes)
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
        if symbol != :button_down || symbol != :button_up
          previous_game_state.__send__(symbol, *args)
        end
      end
      
    end
  end
end
