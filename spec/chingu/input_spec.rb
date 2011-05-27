require 'spec_helper'

describe Chingu::Input do
  it "should map all defined Gosu input constants to Chinu symbols" do
    # Simpler if all the inputs are in a big hash.
    input_names = Gosu.constants.select {|constant| constant =~ /^(?:Kb|Ms|Gp)/ }
    input_names.delete_if {|name| name.to_s =~ /Range(?:Start|End)|Num$/ } # Special entries.
    gosu_inputs = input_names.inject({}) {|hash, name| hash[name] = Gosu.const_get name; hash }

    gosu_inputs.each_value do |code|
      next if code==0 # todo, check into this, spooner? ;)
      symbols = described_class::CONSTANT_TO_SYMBOL[code]
      symbols.should_not be_empty
      symbols.each {|s| s.should be_kind_of Symbol }
    end
  end

  it "should map all Chingu symbols to Gosu input codes" do
    described_class::CONSTANT_TO_SYMBOL.values.flatten.uniq.each do |symbol|
      described_class::SYMBOL_TO_CONSTANT[symbol].should be_kind_of Fixnum
    end
  end
end