#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu

# Show the user which Gosu codes and Chingu symbols that each key maps to.
class Game < Chingu::Window
  def initialize
    super(640,480,false) # leave it blank and it will be 800,600,non fullscreen
    self.caption = "Press a key or mouse/gamepad button to see the input code"

    @gosu_text = Chingu::Text.create('Gosu code (Fixnum) =>', :x => 25, :y => 200, :size => 18)
    @chingu_text = Chingu::Text.create('Chingu name(s) (Symbol) =>', :x => 25, :y => 250, :size => 18)

    input_names = Gosu.constants.select {|constant| constant =~ /^(?:Kb|Ms|Gp)/ }
    input_names.delete_if {|name| name.to_s =~ /Range(?:Start|End)|Num$/ } # Special entries.
    @gosu_inputs = input_names.inject({}) {|hash, name| hash[Gosu.const_get name] = name; hash }

    # Get all possible key codes.
    @key_codes = (Gosu::KbRangeBegin..Gosu::KbRangeEnd).to_a + (Gosu::GpRangeBegin..Gosu::GpRangeEnd).to_a + (Gosu::MsRangeBegin..Gosu::MsRangeEnd).to_a
  end

  def update
    super

    @code = nil
    @key_codes.each do |code|
      if button_down?(code)
        @gosu_text.text = "Gosu code (Fixnum) => #{code} (Gosu::#{@gosu_inputs[code] || "<not defined>"})"
        symbols = Chingu::Input::CONSTANT_TO_SYMBOL[code].map {|s| s.inspect }.join(", ") rescue "<none defined>"
        @chingu_text.text = "Chingu name(s) (Symbol) => #{symbols}"
        break
      end
    end
  end
end



Game.new.show