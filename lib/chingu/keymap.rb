module Chingu
	module Keymap
		include Gosu::Button
				
		CONSTANT_TO_SYMBOL = {
			KbLeft => :left,
			KbRight => :right,
			KbUp => :up,
			KbDown => :down,
			KbEscape => :escape,
			KbSpace => :space,
			KbLeftControl => :left_ctrl,
			KbRightControl => :right_ctrl,
			KbA => :a
		}
		
		SYMBOL_TO_CONSTANT = CONSTANT_TO_SYMBOL.invert.dup
	end
end
