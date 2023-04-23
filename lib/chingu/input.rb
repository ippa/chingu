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
    include Gosu
    
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
      KbLeftMeta    => [:left_meta, :lmeta],

      KbComma           => [:",", :comma],
      KbApostrophe      => [:"'", :apostrophe],
      KbBacktick        => [:"~", :backtick],
      KbMinus           => [:minus],
      KbEqual           => [:"=", :equal],
      KbBracketLeft     => [:"}", :bracket_left],
      KbBracketRight    => [:"{", :bracket_right],
      KbBackslash       => [:backslash],
      KbSlash           => [:slash],
      KbSemicolon       => [:";", :semicolon],
      KbPeriod          => [:period],
      KbISO             => [:ISO],

      KbNumpadAdd       => [:"+", :add, :plus],
      KbNumpadDivide    => [:"/", :divide],
      KbNumpadMultiply  => [:"*", :multiply],
      KbNumpadSubtract  => [:"-", :subtract, :numpad_minus, :nm_minus],
      KbPageDown        => [:page_down],
      KbPageUp          => [:page_up],
      KbPause           => [:pause],
      KbReturn          => [:return],
      KbRight           => [:right_arrow, :right],
      KbRightAlt        => [:right_alt, :ralt],
      KbRightControl    => [:right_control, :right_ctrl, :rctrl],
      KbRightShift      => [:right_shift, :rshift],
      KbRightMeta       => [:right_meta, :rmeta],
      KbSpace           => [:" ", :space],
      KbTab             => [:tabulator, :tab],
      KbUp              => [:up_arrow, :up],
      KbPrintScreen     => [:print_screen],
      KbScrollLock      => [:scroll_lock],
      KbCapsLock        => [:caps_lock],
      KbNumpadDelete    => [:numpad_delete],
      
      MsLeft            => [:left_mouse_button, :mouse_left],
      MsMiddle          => [:middle_mouse_button, :mouse_middle],
      MsRight           => [:right_mouse_button, :mouse_right],
      MsWheelDown       => [:mouse_wheel_down, :wheel_down],
      MsWheelUp         => [:mouse_wheel_up, :wheel_up],

      GpDpadLeft        => [:dpad_left],
      GpDpadRight       => [:dpad_right],
      GpDpadUp          => [:dpad_up],
      GpDpadDown        => [:dpad_down],
      GpLeftStickYAxis  => [:left_stick_y_axis],
      GpRightStickYAxis  => [:right_stick_y_axis],
      GpLeftStickXAxis  => [:left_stick_x_axis],
      GpRightStickXAxis  => [:right_stick_x_axis],
    }

    # MsOther, 0-7
    (0..7).each do |number|
      CONSTANT_TO_SYMBOL[eval("MsOther#{number}")] = ["ms_other_#{number.to_s}".to_sym]
    end
    
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
      CONSTANT_TO_SYMBOL[eval("KbF#{number.to_s}")] = ["f#{number.to_s}".to_sym, "F#{number.to_s}".to_sym]
    end

    (0..3).each do |number|
      CONSTANT_TO_SYMBOL[eval("Gp#{number.to_s}DpadLeft")] = ["dpad_#{number.to_s}_left".to_sym]
      CONSTANT_TO_SYMBOL[eval("Gp#{number.to_s}DpadRight")] = ["dpad_#{number.to_s}_right".to_sym]
      CONSTANT_TO_SYMBOL[eval("Gp#{number.to_s}DpadUp")] = ["dpad_#{number.to_s}_up".to_sym]
      CONSTANT_TO_SYMBOL[eval("Gp#{number.to_s}DpadDown")] = ["dpad_#{number.to_s}_down".to_sym]
    end

    def gamepad_key(number, key, args = {})
      number = number.zero? ? '' : number - 1

      constant_name = "Gp#{number}"
      constant_name += args[:prefix].to_s.capitalize
      constant_name += key.to_s.to_s.capitalize

      CONSTANT_TO_SYMBOL[eval(constant_name)] = [
          "gamepad_button#{number}_#{key}".to_sym,
          "gamepad#{number}_#{key}".to_sym,
          "pad_button#{number}_#{key}".to_sym,
          "pad#{number}_#{key}".to_sym,
          "gp#{number}_#{key}".to_sym
      ]
    end

    module_function :gamepad_key

    # Gamepads
    (0..4).each do |gp_number|
      gamepad_key(gp_number, :down)
      gamepad_key(gp_number, :left)
      gamepad_key(gp_number, :right)
      gamepad_key(gp_number, :up)

      # Gamepad-buttons 0-15
      (0..15).each { |n| gamepad_key(gp_number, n, prefix: 'button') }
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
