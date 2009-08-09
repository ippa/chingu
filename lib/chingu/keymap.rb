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
			KbRightControl => :right_ctrl
		}
    
    ("A".."Z").each do |letter|
      CONSTANT_TO_SYMBOL[eval("Kb#{letter}")] = letter.downcase.to_sym
    end
      
		SYMBOL_TO_CONSTANT = CONSTANT_TO_SYMBOL.invert.dup
	end
end
