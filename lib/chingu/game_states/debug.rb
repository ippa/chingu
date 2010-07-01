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
    # Debug game state (F1 is default key to start/exit debug win, 'p'
    # to pause game)
    #
    # Usage: 
    #  
    class Debug < Chingu::GameState
      include Chingu::Helpers::OptionsSetter
      
      attr_accessor :fade_color, :text_color, :text, :x_offset, :y_offset
      
      # TODO - centralize!
      Z = 999

      DEFAULTS = {
        :x_offset => 10,
        :y_offset => 10,
        :text_color => Gosu::Color.new(255,255,255,255),
        :fade_color => Gosu::Color.new(100,100,100,70),
        :paused => false
      }

      def initialize(options = {})
        super
        set_options(options, DEFAULTS)

        # it fails when setup in DEFAULTS as it needs existing $window
        @font ||= Gosu::Font.new($window, Gosu::default_font_name, 16)
        
        self.input = {:p => :pause, :f1 => :return_to_game, :esc => :return_to_game}
      end
    
      def return_to_game
        game_state_manager.pop_game_state
      end
      
      def pause
        @paused = !@paused
      end
      
      def update
        game_state_manager.previous_game_state.update unless @paused
      end
      
      def draw
        previous_state.draw unless previous_state.nil?

        $window.draw_quad(  0,0,@fade_color,
                            $window.width,0,@fade_color,
                            $window.width,$window.height,@fade_color,
                            0,$window.height,@fade_color,10)                       
        
        @font.draw("DEBUG CONSOLE", @x_offset, @y_offset, Z)       
        print_lines(@text || generate_info)
      end

      protected
      
      def print_lines(text)
        height = @font.height
        lines = text.respond_to?(:lines) ? text.lines : text
        
        lines.each_with_index do |line,i|
          @font.draw(line, @x_offset, @y_offset + height * (i+3), Z,1,1, @text_color)
        end       
      end

      def generate_info
        info = ''
        info << previous_state.to_s

        info << "\nObjects\n"         

        previous_state.game_objects.each do |o|
          info << "  #{o.class.to_s}: #{o.to_s}\n"
        end

        info
      end

      def previous_state
        game_state_manager.previous_game_state        
      end
      
    end
  end
end
