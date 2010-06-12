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
        @debug = options[:debug]
        @file = options[:file] || "#{previous_game_state.class.to_s.downcase}.yml"
        @zorder = 10000
        
        @hud_color = Gosu::Color.new(150,100,100,100)
        @selected_game_object = nil        
        self.input =  { :left_mouse_button => :left_mouse_button, 
                        :released_left_mouse_button => :released_left_mouse_button,
                        :right_mouse_button => :right_mouse_button, 
                        :released_right_mouse_button => :released_right_mouse_button,                        
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
        
        x = 20
        y = 60
        @classes.each do |klass|
          puts "Creating a #{klass}"  if @debug
          
          # We initialize x,y,zorder,rotation_center after creation
          # so they're not overwritten by the class initialize/setup or simular
          game_object = klass.create
          game_object.x = x
          game_object.y = y
          game_object.zorder = @zorder
          
          # Scale down big objects, don't scale objects under [32, 32]
          if game_object.image
            game_object.factor_x = 32 / game_object.image.width   if game_object.image.width > 32
            game_object.factor_y = 32 / game_object.image.height  if game_object.image.height > 32
          end
          x += 40
        end
      end
            
      def setup                        
        @title = Text.create("File: #{@file}", :x => 5, :y => 2, :factor => 1, :size => 16, :zorder => @zorder)
        @title.text += " - Grid: #{@grid}" if @grid
        @text = Text.create("", :x => 200, :y => 20, :factor => 1, :size => 16, :zorder => @zorder)
        @status_text = Text.create("-", :x => 5, :y => 20, :factor => 1, :size => 16, :zorder => @zorder)
        #@title2 = Text.create("(1-10) Create object at mouse pos  (DEL) Delete selected object  (S) Save  (E) Save and Quit  (ESC) Quit without saving", :x => 5, :y => 30, :factor => 1)
      end
      
      def create_object_nr(number)
        c = @classes[number].create(:x => x, :y => y, :parent => previous_game_state)  if @classes[number]
        c.update
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
        # Sync all changes to previous game states game objects list
        # This is needed since we don't call update on it.
        previous_game_state.game_objects.sync
        
        super
        
        #
        # We got a selected game object
        #
        if @selected_game_object
          @text.text = "#{@selected_game_object.class.to_s} @ #{@selected_game_object.x} / #{@selected_game_object.y} - zorder: #{@selected_game_object.zorder}"
        end
        
        #
        # We got a selected game object and the left mouse button is held down
        #
        if @left_mouse_button && @selected_game_object
          selected_game_objects.each do |selected_game_object|            
            selected_game_object.x = self.x + selected_game_object.options[:mouse_x_offset]
            selected_game_object.y = self.y + selected_game_object.options[:mouse_y_offset]
            selected_game_object.x -= selected_game_object.x % @grid[0]
            selected_game_object.y -= selected_game_object.y % @grid[1]
          end
          
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
       
      #
      # CLICKED LEFT MOUSE BUTTON
      #
      def left_mouse_button
        @left_mouse_button = true
        
        if @cursor_game_object && game_object_at(x, y)==nil && game_object_icon_at($window.mouse_x, $window.mouse_y) == nil
          game_object = @cursor_game_object.class.create(:parent => previous_game_state)
          game_object.update
          game_object.options[:selected] = true
          game_object.x = x
          game_object.y = y
        end
        
        # Get editable game object that was clicked at (if any)
        @selected_game_object = game_object_at(x, y)
        
        # Check if user clicked on anything in the icon-toolbar of available game objects
        @cursor_game_object = game_object_icon_at($window.mouse_x, $window.mouse_y)
              
        if @selected_game_object
          #
          # If clicking on a new object that's wasn't previosly selected
          #  --> deselect all objects unless holding left_ctrl
          #
          if @selected_game_object.options[:selected] == nil
            selected_game_objects.each { |x| x.options[:selected] = nil } unless holding?(:left_ctrl)
          end
          
          @selected_game_object.options[:selected] = true
          #
          # Re-align all objects x/y offset in relevance to the cursor
          #
          selected_game_objects.each do |selected_game_object|
            selected_game_object.options[:mouse_x_offset] = selected_game_object.x - self.x
            selected_game_object.options[:mouse_y_offset] = selected_game_object.y - self.y
          end
        else
          selected_game_objects.each { |x| x.options[:selected] = nil } unless holding?(:left_ctrl)
        end
      end
      
      def right_mouse_button
        @cursor_game_object = game_object_at(x, y)
        selected_game_objects.each { |x| x.options[:selected] = nil }
      end
      def released_right_mouse_button
      end
      
      #
      # RELASED LEFT MOUSE BUTTON
      #
      def released_left_mouse_button
        @left_mouse_button = false
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

      def game_object_classes
        ObjectSpace.enum_for(:each_object, class << GameObject; self; end).to_a.select do |game_class|
          game_class.instance_methods
        end
      end
      
      def page_up
        selected_game_objects.each { |game_object| game_object.zorder += 1 }
        #self.previous_game_state.viewport.y -= $window.height if defined?(self.previous_game_state.viewport)
      end
      def page_down
        selected_game_objects.each { |game_object| game_object.zorder -= 1 }
        #self.previous_game_state.viewport.y += $window.height if defined?(self.previous_game_state.viewport)
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
