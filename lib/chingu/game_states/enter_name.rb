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
    # A Chingu::GameState for showing a classic arcade "enter name" screen.
    # Will let the user enter his alias or name with the keyboard or game_pad
    # Intended to be minimalistic. If you wan't something flashy you probably want to do this class yourself.
    #  
    class EnterName < Chingu::GameState
  
      def initialize(options = {})
        super
    
        Text.create("Please enter your name:", :x => 0, :y => 0, :size => 40)
    
        on_input([:holding_left, :holding_a, :holding_gamepad_left], :left)
        on_input([:holding_right, :holding_d, :holding_gamepad_right], :right)
        on_input([:space, :x, :enter, :gamepad_button_1, :return], :action)
        on_input(:esc, :pop_game_state)
        
        @callback = options[:callback]
        
        @string = []
        @texts = []
        @start_y = 100
        @start_x = 0
        @index  = 1
        #@letters = %w[ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ! " # % & ( ) [ ] = * _ < GO! ]
        @letters = %w[ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ! _ < GO! ]
        x = @start_x
        
        @letter_spacing = 20
        
        @letters.each do |letter|
          @texts << Text.create(letter, :x => x, :y => @start_y, :rotation_center => :bottom_left, :size => 22)
          x += @letter_spacing
        end
      
        @selected_color = Color::RED
        @signature = Text.create("", :x => $window.width/2, :y => $window.height/2, :size => 80, :align => :center)
      end
    
      # Move cursor 1 step to the left
      def left; move_cursor(-1); end
      
      # Move cursor 1 step to the right
      def right; move_cursor(1); end
      
      # Move cursor any given value (positive or negative). Used by left() and right()
      def move_cursor(amount = 1)
        @index += amount
        @index = 1                if @index >= @letters.size
        @index = @letters.size-1  if @index < 0
        sleep(0.1)
      end
  
      def action
        case @letters[@index]
          when "<"    then  @string.pop
          when "_"    then  @string << " "
          when "GO!"  then  go
          else              @string << @letters[@index]
        end
    
        @signature.text = @string.join
        @signature.x = $window.width/2 - @signature.width/2
      end
    
      def draw
        @rect = Rect.new(@start_x + (@letter_spacing * @index), @start_y+@letter_spacing, @texts[@index].width, 10)
        fill_rect(@rect, @selected_color, 0)
        super
      end
  
      def go
        @callback.call(@string.join)
        pop_game_state
      end
      
    end
  end
end
