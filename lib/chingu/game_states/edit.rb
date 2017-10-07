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
    # requires the global $window set to the instance of Gosu::Window (automaticly handled if you use Chingu::Window)  # FIXME what if $window is nil?
    #
    # Edit will only edit game objects created with the editor itself or that's been loaded with load_game_objects.
    # This makes mixing of loaded game objects and code create game objects possible, in the game, and in the editor.
    #
    # Various shortcuts are available in the editor
    #
    # 1-5: create object 1..5 shown in toolbar
    # DEL: delete selected objects
    # CTRL+A: select all objects (not code-created ones though)
    # S: Save
    # E: Save and Quit
    # Right Mouse Button Click: Copy object that was clicked on for fast duplication
    # Arrows: Scroll within a viewport
    # Page up/down: Modify the zorder of selected game objects
    #
    class Edit < Chingu::GameState
      attr_accessor :grid, :debug, :file, :hud_color
      attr_reader :classes, :exclude

      def initialize(options = {})
        super
                
        options = {:draw_grid => true, :snap_to_grid => true, :resize_to_grid => true}.merge(options)
        
        @grid = options[:grid] || [8,8]
        @grid_color = options[:grid_color] || Gosu::Color.new(0xaa222222)
        @draw_grid = options[:draw_grid]
        @snap_to_grid = options[:snap_to_grid]      # todo
        @resize_to_grid = options[:resize_to_grid]  # todo
        
        @classes = Array(options[:classes] || game_object_classes)
        @except = options[:except] || []
        @classes -= Array(@except)
        @debug = options[:debug]
        @attributes = options[:attributes] || [:x, :y, :angle, :zorder, :factor_x, :factor_y, :alpha]

        #
        # Turn on cursor + turn it back to its original value in finalize()
        #
        @original_cursor = $window.cursor # FIXME what if $window is nil?
        $window.cursor = true # FIXME what if $window is nil?
        
        p @classes  if @debug

        @hud_color = Gosu::Color.new(200,70,70,70)
        @selected_game_object = nil
        self.input =  {
          :f1 => :display_help,
          :left_mouse_button => :left_mouse_button,
          :released_left_mouse_button => :released_left_mouse_button,
          :right_mouse_button => :right_mouse_button,
          :released_right_mouse_button => :released_right_mouse_button,

          :delete    => :destroy_selected_game_objects,
          :d         => :destroy_selected_game_objects,
          :backspace => :reset_selected_game_objects,

          :holding_numpad_7 => :scale_down,
          :holding_numpad_9 => :scale_up,
          :holding_numpad_4 => :tilt_left,
          :holding_numpad_8 => :tilt_right,
          :holding_numpad_1 => :dec_alpha,
          :holding_numpad_3 => :inc_alpha,

          :r => :scale_up,
          :f => :scale_down,
          :t => :tilt_left,
          :g => :tilt_right,
          :y => :inc_zorder,
          :h => :dec_zorder,
          :u => :inc_alpha,
          :j => :dec_alpha,

          :page_up => :inc_zorder,
          :page_down => :dec_zorder,

          :s => :try_save,
          :a => :try_select_all,

          :e => :save_and_quit,

          :esc => :esc,
          :q => :quit,

          :up_arrow => :move_up,
          :down_arrow => :move_down,
          :left_arrow => :move_left,
          :right_arrow => :move_right,

          :holding_up_arrow => :try_scroll_up,
          :holding_down_arrow => :try_scroll_down,
          :holding_left_arrow => :try_scroll_left,
          :holding_right_arrow => :try_scroll_right,

          :plus => :scale_up,
          :minus => :scale_down,
          :mouse_wheel_up => :mouse_wheel_up,
          :mouse_wheel_down => :mouse_wheel_down,

          :"1" => :create_object_1,
          :"2" => :create_object_2,
          :"3" => :create_object_3,
          :"4" => :create_object_4,
          :"5" => :create_object_5,
        }

        @hud_height = 140
        @toolbar_icon_size = [32,32]
        draw_toolbar_objects
      end

      def draw_toolbar_objects
        x = 20
        y = 60
        @classes.each do |klass|
          puts "Creating a #{klass}"  if @debug

          # We initialize x,y,zorder,rotation_center after creation
          # so they're not overwritten by the class initialize/setup or simular
          begin
            game_object = klass.create(:paused => true)
            game_object.x = x + 10
            game_object.y = y
            game_object.options[:toolbar] = true
            game_object.rotation_center = :center_center

            # Scale down object to fit our toolbar
            if game_object.image
              Text.create("#{klass.to_s[0..9]}\n#{game_object.width.to_i}x#{game_object.height.to_i}", :size => 12, :x=>x-16, :y=>y+18, :max_width => 55, :rotation_center => :top_left, :align => :center, :factor => 1)
              game_object.size = @toolbar_icon_size
              x += 50
            else
              puts "Skipping #{klass} - no image" if @debug
              game_object.destroy
            end
          rescue
            puts "Couldn't use #{klass} in editor: #{$!}"
          end
        end        
      end
      def display_help
text = <<END_OF_STRING
  F1: This help screen
  ESC: Return to Edit
  
  1-5: create object 1..5 shown in toolbar at mousecursor
  CTRL+A: select all objects (not in-code-created ones though)
  CTRL+S: Save
  E: Save and Quit
  Q: Quit (without saving)
  ESC: Deselect all objects
  Right Mouse Button Click: Copy object bellow cursor for fast duplication
  Arrow-keys (with selected objects): Move objects 1 pixel at the time
  Arrow-keys (with no selected objects): Scroll within a viewport
  

  Bellow keys operates on all currently selected game objects
  -----------------------------------------------------------------------------------
  DEL: delete selected objects
  BACKSPACE: reset angle and scale to default values
  Page Up: Increase zorder
  Page Down: Decrease zorder
  
  R: scale up
  F: scale down
  T: tilt left
  G: tilt right
  Y: inc zorder
  H: dec zorder
  U: less transparency
  J: more transparencty

  Mouse Wheel (with no selected objects): Scroll viewport up/down
  Mouse Wheel: Scale up/down
  SHIFT + Mouse Wheel: Tilt left/right
  CTRL + Mouse Wheel: Zorder up/down
  ALT + Mouse Wheel: Transparency less/more
END_OF_STRING
        
        push_game_state( GameStates::Popup.new(:text => text) )
      end
      
      def draw_grid
        return unless @grid
        
        start_x, start_y = 0,0
        if defined?(previous_game_state.viewport)
          start_x = -previous_game_state.viewport.x % @grid.first
          start_y = -previous_game_state.viewport.y % @grid.last
        end
        (start_x .. $window.width).step(@grid.first).each do |x|
          $window.draw_line(x, 1, @grid_color, x, $window.height, @grid_color, 0, :additive) # FIXME what if $window is nil?
        end
        (start_y .. $window.height).step(@grid.last).each do |y|
          $window.draw_line(1, y, @grid_color, $window.width, y, @grid_color, 0, :additive) # FIXME what if $window is nil?
        end
        
      end

      #
      # SETUP
      #
      def setup
        @scroll_border_thickness = 30
        @file = options[:file] || previous_game_state.filename + ".yml"
        @title = Text.create("File: #{@file}", :x => 5, :y => 2, :factor => 1, :size => 16)
        @title.text += " - Grid: #{@grid}" if @grid
        @text = Text.create("", :x => 300, :y => 20, :factor => 1, :size => 16)
        @status_text = Text.create("-", :x => 5, :y => 20, :factor => 1, :size => 16)
        
        if defined?(previous_game_state.viewport)
          @game_area_backup = previous_game_state.viewport.game_area.dup
          previous_game_state.viewport.game_area.x -= @hud_height
          previous_game_state.viewport.game_area.y -= @hud_height
        end
      end
                  
      #
      # UPDATE
      #
      def update        
        super
        
        @status_text.text = "#{self.mouse_x.to_i} / #{self.mouse_y.to_i}"
    
        @text.text = @selected_game_object.to_s
        
        #
        # We got a selected game object and the left mouse button is held down
        #
        if @left_mouse_button && @selected_game_object
          selected_game_objects.each do |selected_game_object|            
            selected_game_object.x = self.mouse_x + selected_game_object.options[:mouse_x_offset]
            selected_game_object.y = self.mouse_y + selected_game_object.options[:mouse_y_offset]
            
            if @snap_to_grid
              selected_game_object.x -= selected_game_object.x % @grid[0]
              selected_game_object.y -= selected_game_object.y % @grid[1]
            end
          end
        elsif @left_mouse_button
          if defined?(self.previous_game_state.viewport)
            self.previous_game_state.viewport.x = @left_mouse_click_at[0] - $window.mouse_x # FIXME what if $window is nil?
            self.previous_game_state.viewport.y = @left_mouse_click_at[1] - $window.mouse_y # FIXME what if $window is nil?
          end
        end
        
        if inside_window?($window.mouse_x, $window.mouse_y)
          scroll_right  if $window.mouse_x > $window.width - @scroll_border_thickness # FIXME what if $window is nil?
          scroll_left   if $window.mouse_x < @scroll_border_thickness # FIXME what if $window is nil?
          scroll_up     if $window.mouse_y < @scroll_border_thickness # FIXME what if $window is nil?
          scroll_down   if $window.mouse_y > $window.height - @scroll_border_thickness # FIXME what if $window is nil?
        end
      end
      
      #
      # DRAW
      #
      def draw
        # Draw prev game state onto screen (the level we're editing)
        previous_game_state.draw
        
        # Restart z-ordering, everything after this will be drawn on top
        $window.flush  # FIXME what if $window is nil?
                
        draw_grid if @draw_grid
        
        #
        # Draw an edit HUD
        #
        $window.draw_quad(  0,0,@hud_color, $window.width,0,@hud_color,
                            $window.width,@hud_height,@hud_color,0,@hud_height,@hud_color) # FIXME what if $window is nil?
             
        #
        # Draw gameobjects
        #
        super
                
        #
        # Draw red rectangles/circles around all selected game objects
        #        
        if defined?(previous_game_state.viewport)
          previous_game_state.viewport.apply { draw_selections }
        else
          draw_selections
        end
        
        @cursor_game_object.draw_at($window.mouse_x, $window.mouse_y)   if @cursor_game_object  # FIXME what if $window is nil?
      end
      
      #
      # Draw a red rectangle around all selected objects
      #
      def draw_selections
        selected_game_objects.each { |game_object| draw_rect(bounding_box(game_object), Color::RED, 10000) }
      end
      
      #
      # CLICKED LEFT MOUSE BUTTON
      #
      def left_mouse_button
        @left_mouse_button  = true
        @selected_game_object = false
        
        if defined?(self.previous_game_state.viewport)
          @left_mouse_click_at = [self.previous_game_state.viewport.x + $window.mouse_x, self.previous_game_state.viewport.y + $window.mouse_y]  # FIXME what if $window is nil?
        else
          @left_mouse_click_at = [$window.mouse_x, $window.mouse_y]  # FIXME what if $window is nil?
        end
        
        # Put out a new game object in the editor window and select it right away
        @selected_game_object = copy_game_object(@cursor_game_object)  if @cursor_game_object
        
        # Check if user clicked on anything in the icon-toolbar of available game objects
        @cursor_game_object = game_object_icon_at($window.mouse_x, $window.mouse_y)  # FIXME what if $window is nil?

        # Get editable game object that was clicked at (if any)
        @selected_game_object ||= game_object_at(self.mouse_x, self.mouse_y)
        
        if @selected_game_object && defined?(self.previous_game_state.viewport)
          self.previous_game_state.viewport.center_around(@selected_game_object)  if @left_double_click
        end
                      
        if @selected_game_object
          #
          # If clicking on a new object that's wasn't previosly selected
          #  --> deselect all objects unless holding left_ctrl
          #
          if @selected_game_object.options[:selected] == nil
            selected_game_objects.each { |object| object.options[:selected] = nil } unless holding?(:left_ctrl)
          end
          
          if holding?(:left_ctrl)
            @selected_game_object.options[:selected] = !@selected_game_object.options[:selected]
          else
            @selected_game_object.options[:selected] = true
          end
          
          if holding?(:left_shift)
            previous_game_state.game_objects.select { |x| x.class == @selected_game_object.class }.each do |game_object|
              game_object.options[:selected] = true
            end
          end
            
          #
          # Re-align all objects x/y offset in relevance to the cursor
          #
          selected_game_objects.each do |selected_game_object|
            selected_game_object.options[:mouse_x_offset] = selected_game_object.x - self.mouse_x
            selected_game_object.options[:mouse_y_offset] = selected_game_object.y - self.mouse_y
          end
        else
          deselect_selected_game_objects unless holding?(:left_ctrl)
        end
      end
      
      def right_mouse_button
        @cursor_game_object = @cursor_game_object ?  nil : game_object_at(mouse_x, mouse_y)
      end
      def released_right_mouse_button
      end
            
      #
      # RELASED LEFT MOUSE BUTTON
      #
      def released_left_mouse_button
        @left_mouse_button = false
      end

      #
      # Returns a list of game objects the editor can create. 2 types of object gets this flag:
      # - An object loaded with load_game_objects
      # - An object created from within the editor
      #
      # This helps us mix code-created with editor-created objects inside the editor and not muck around with
      # the code-created ones.
      #
      def editable_game_objects
        previous_game_state.game_objects.select { |o| o.options[:created_with_editor] }
      end
      
      #
      # Returns a list of selected game objects
      #
      def selected_game_objects
        editable_game_objects.select { |o| o.options[:selected] }
      end
      
      #
      # Call destroy on all selected game objects
      #
      def destroy_selected_game_objects
        selected_game_objects.each { |game_object| game_object.destroy }
      end

      def deselect_selected_game_objects
        selected_game_objects.each { |object| object.options[:selected] = nil }
      end
      
      def empty_area_at_cursor
        game_object_at(self.mouse_x, self.mouse_y)==nil && 
        game_object_icon_at($window.mouse_x, $window.mouse_y) == nil
      end

      #
      # Get all classes based on GameObject except Chingus internal classes.
      #
      def game_object_classes
        ObjectSpace.enum_for(:each_object, class << GameObject; self; end).to_a.select do |game_class|
          game_class.instance_methods && !game_class.to_s.include?("Chingu::")
        end
      end      
      
      def create_object_nr(number)
        c = @classes[number].create(:x => self.mouse_x, :y => self.mouse_y, :parent => previous_game_state)  if @classes[number]
        c.options[:created_with_editor] = true
        c.update
        #@text.text = "Created a #{c.class} @ #{c.x} / #{c.y}"
      end
      
      def create_object_1; create_object_nr(0); end
      def create_object_2; create_object_nr(1); end
      def create_object_3; create_object_nr(2); end
      def create_object_4; create_object_nr(3); end
      def create_object_5; create_object_nr(4); end

      #
      # Resets selected game objects defaults, angle=0, scale=1.
      #
      def reset_selected_game_objects
        selected_game_objects.each do |game_object|
          game_object.angle = 0
          game_object.scale = 1
        end
      end

      def game_object_icon_at(x, y)
        game_objects.select do |game_object|
          next if game_object.is_a? Text
          next unless game_object.image
          bounding_box(game_object).collide_point?(x,y)
        end.first
      end

      #
      # Get editable object at X/Y .. if there's many objects at the same coordinate..
      # .. get the one with highest zorder.
      #
      def game_object_at(x, y)
        editable_game_objects.select do |game_object|
          next if game_object.is_a? Text
          bounding_box(game_object).collide_point?(x,y)
        end.sort {|x,y| y.zorder <=> x.zorder }.first
      end

      def try_select_all
        editable_game_objects.each { |x| x.options[:selected] = true }  if holding?(:left_ctrl)
      end
      def try_save
        save if holding?(:left_ctrl)
      end
      def quit
        pop_game_state
      end
      def save 
        save_game_objects(:game_objects => editable_game_objects, :file => @file, :classes => @classes, :attributes => @attributes)
      end
      def save_and_quit
        save unless holding?(:left_ctrl)
        quit
      end

      def finalize
        if defined?(previous_game_state.viewport)
          previous_game_state.viewport.game_area = @game_area_backup
        end
        $window.cursor = @original_cursor  # FIXME what if $window is nil?
      end
            
      def move_left
        scroll_left && return   if selected_game_objects.empty?
        selected_game_objects.each { |game_object| game_object.x -= 1 }
      end
      def move_right
        scroll_right && return  if selected_game_objects.empty?
        selected_game_objects.each { |game_object| game_object.x += 1 }
      end
      def move_up
        scroll_up && return     if selected_game_objects.empty?
        selected_game_objects.each { |game_object| game_object.y -= 1 }
      end
      def move_down
        scroll_down && return   if selected_game_objects.empty?
        selected_game_objects.each { |game_object| game_object.y += 1 }
      end
      
      def try_scroll_left
        scroll_left if selected_game_objects.empty?
      end
      def try_scroll_right
        scroll_right if selected_game_objects.empty?
      end
      def try_scroll_up
        scroll_up   if selected_game_objects.empty?
      end
      def try_scroll_down
        scroll_down if selected_game_objects.empty?
      end
      
      def mouse_wheel_up
        if selected_game_objects.empty?
          scroll_up(40)
        else
          tilt_left && return if holding?(:left_shift)
          inc_zorder && return if holding?(:left_ctrl)
          inc_alpha && return if holding?(:left_alt)
          scale_up
        end
      end

      def mouse_wheel_down
        if selected_game_objects.empty?
          scroll_down(40)
        else
          tilt_right && return if holding?(:left_shift)
          dec_zorder && return if holding?(:left_ctrl)
          dec_alpha && return if holding?(:left_alt)
          scale_down
        end
      end
      
      def tilt_left
        selected_game_objects.each { |game_object| game_object.angle -= 5 }
      end
      def tilt_right
        selected_game_objects.each { |game_object| game_object.angle += 5 }        
      end
      def scale_up
        scale_up_x && scale_up_y
      end
      def scale_down
        scale_down_x && scale_down_y
      end
      
      def inc_zorder
        selected_game_objects.each { |game_object| game_object.zorder += 1 }
      end
      def dec_zorder
        selected_game_objects.each { |game_object| game_object.zorder -= 1 }
      end
      def inc_alpha
        selected_game_objects.each { |game_object| game_object.alpha += 1 }
      end
      def dec_alpha
        selected_game_objects.each { |game_object| game_object.alpha -= 1 }
      end
      def scale_up_x
        selected_game_objects.each { |game_object| game_object.width += grid[0] }
      end
      def scale_up_y
        selected_game_objects.each { |game_object| game_object.height += grid[1] }
      end
      def scale_down_x
        selected_game_objects.each { |game_object| game_object.width -= grid[0] if game_object.width > grid[0] }
      end
      def scale_down_y
        selected_game_objects.each { |game_object| game_object.height -= grid[1] if game_object.height > grid[1] }
      end
            
      def esc
        deselect_selected_game_objects
        @cursor_game_object = nil
      end
      def page_up
        self.previous_game_state.viewport.y -= $window.height if defined?(self.previous_game_state.viewport)  # FIXME what if $window is nil?
      end
      def page_down
        self.previous_game_state.viewport.y += $window.height if defined?(self.previous_game_state.viewport)  # FIXME what if $window is nil?
      end
      def scroll_up(amount = 10)
        self.previous_game_state.viewport.y -= amount if defined?(self.previous_game_state.viewport)
      end
      def scroll_down(amount = 10)
        self.previous_game_state.viewport.y += amount if defined?(self.previous_game_state.viewport)
      end
      def scroll_left(amount = 10)
        self.previous_game_state.viewport.x -= amount if defined?(self.previous_game_state.viewport)
      end
      def scroll_right(amount = 10)
        self.previous_game_state.viewport.x += amount if defined?(self.previous_game_state.viewport)
      end
      
      def mouse_x
        x = $window.mouse_x # FIXME what if $window is nil?
        x += self.previous_game_state.viewport.x if defined?(self.previous_game_state.viewport)
        return x
      end
      
      def mouse_y
        y = $window.mouse_y # FIXME what if $window is nil?
        y += self.previous_game_state.viewport.y if defined?(self.previous_game_state.viewport)
        return y
      end

      def inside_window?(x = $window.mouse_x, y = $window.mouse_y)
        x >= 0 && x <= $window.width && y >= 0 && y <= $window.height  # FIXME what if $window is nil?
      end

      def copy_game_object(template)
        game_object = template.class.create(:parent => previous_game_state)
        # If we don't create it from the toolbar, we're cloning another object
        # When cloning we wan't the cloned objects attributes
        game_object.attributes = template.attributes  unless template.options[:toolbar]       
        game_object.x = self.mouse_x
        game_object.y = self.mouse_y
        game_object.options[:created_with_editor] = true
                
        game_object.options[:mouse_x_offset] = (game_object.x - self.mouse_x) rescue 0
        game_object.options[:mouse_y_offset] = (game_object.y - self.mouse_y) rescue 0
        
        return game_object
      end
      
      CENTER_TO_FACTOR = { 0 => -1, 0.5 => 0, 1 => 1 }
      #
      # Returns a bounding box (Rect-class) for any gameobject
      # It will take into considerations rotation_center and scaling
      #      
      def bounding_box(game_object)
        width, height = game_object.width, game_object.height
        x = game_object.x - width * game_object.center_x
        y = game_object.y - height * game_object.center_y
        x += width * CENTER_TO_FACTOR[game_object.center_x]   if game_object.factor_x < 0
        y += height * CENTER_TO_FACTOR[game_object.center_y]  if game_object.factor_y < 0
        return Rect.new(x, y, width, height)
      end
      alias :bb :bounding_box
        
      
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
