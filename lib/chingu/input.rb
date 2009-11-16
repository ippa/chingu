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
  module Input
    include Gosu::Button
  
    #
    # Ruby symbols describing http://www.libgosu.org/rdoc/classes/Gosu.html
    #
    CONSTANT_TO_SYMBOL = {
      Kb0 => [:zero],
      Kb1 => [:one],
      Kb2 => [:two],
      Kb3 => [:three],
      Kb4 => [:four],
      Kb5 => [:five],
      Kb6 => [:six],
      Kb7 => [:seven],
      Kb8 => [:eight],
      Kb9 => [:nine],
    
      KbBackspace => [:backspace],
      KbDelete    => [:delete, :del],
      KbDown      => [:down_arrow, :down],
      KbEnd       => [:end],
      KbEnter     => [:enter],
      KbEscape    => [:escape, :esc],

      KbHome        => [:home],
      KbInsert      => [:insert, :ins],
      KbLeft        => [:left_arrow, :left],
      KbLeftAlt     => [:left_alt, :lalt],
      KbLeftControl => [:left_control, :left_ctrl, :lctrl],
      KbLeftShift   => [:left_shift, :lshift],
      
      
      KbNumpadAdd       => [:"+", :add],
      KbNumpadDivide    => [:"/", :divide],
      KbNumpadMultiply  => [:"*", :multiply],
      KbNumpadSubtract  => [:"-", :subtract],
      KbPageDown        => [:page_down],
      KbPageUp          => [:page_up],
      # KbPause           => [:pause],
      KbReturn          => [:return],
      KbRight           => [:right_arrow, :right],
      KbRightAlt        => [:right_alt, :ralt],
      KbRightControl    => [:right_control, :right_ctrl, :rctrl],
      KbRightShift      => [:right_shift, :rshift],
      KbSpace           => [:" ", :space],
      KbTab             => [:tabulator, :tab],
      KbUp              => [:up_arrow, :up],
      
      MsLeft            => [:left_mouse_button, :mouse_left],
      MsMiddle          => [:middle_mouse_button, :mouse_middle],
      MsRight           => [:right_mouse_button, :mouse_right],
      MsWheelDown       => [:mouse_wheel_down, :wheel_down],
      MsWheelUp         => [:mouse_wheel_up, :wheel_up],
      
      GpDown            => [:gamepad_down, :gp_down, :pad_down],
      GpLeft            => [:gamepad_left, :gp_left, :pad_left],
      GpRight           => [:gamepad_right, :gp_right, :pad_right],
      GpUp              => [:gamepad_up, :gp_up, :pad_up]
    }
    
    # Letters, A-Z
    ("A".."Z").each do |letter|
      CONSTANT_TO_SYMBOL[eval("Kb#{letter}")] = [letter.downcase.to_sym]
    end

    # Numbers, 0-9
    (0..9).each do |number|
      CONSTANT_TO_SYMBOL[eval("Kb#{number.to_s}")] = [number.to_s.to_sym]
    end

    # Numpad-numbers, 0-9
    (0..9).each do |number|
      CONSTANT_TO_SYMBOL[eval("KbNumpad#{number.to_s}")] = ["numpad_#{number.to_s}".to_sym]
    end

    #F-keys, F1-F12
    (1..12).each do |number|
      CONSTANT_TO_SYMBOL[eval("KbF#{number.to_s}")] = ["f#{number.to_s}".to_sym]
    end

    # Gamepad-buttons 0-15
    (0..15).each do |number|
      CONSTANT_TO_SYMBOL[eval("GpButton#{number.to_s}")] = ["gamepad_button_#{number.to_s}"]
    end

    #
    # Reverse CONSTANT_TO_SYMBOL -> SYMBOL_TO_CONSTNT
    # like: SYMBOL_TO_CONSTANT = CONSTANT_TO_SYMBOL.invert.dup
    #
    SYMBOL_TO_CONSTANT = Hash.new
    CONSTANT_TO_SYMBOL.each_pair do |constant, symbols|
      symbols.each do |symbol|
        SYMBOL_TO_CONSTANT[symbol] = constant
      end
    end
    
  end
end
