require 'spec_helper'

class Car  
  include Chingu::Helpers::OptionsSetter

  attr_accessor :angle, :speed
  attr_reader :color
  
  def initialize(params)
    set_options(params, { :angle => 11, :speed => 22 })
  end
end


module Chingu
  module Helpers   
    describe OptionsSetter do
      
      context "using without defaults" do
        before do
          @car = Car.new(:angle => 44)
        end

        it "should set angle from options" do
          @car.angle.should == 44
        end

        it "should set speed from defaults" do
          @car.speed.should == 22  
        end

        it "should handle attribute without writer" do
          Car.new(:color => :green).color.should == :green
        end
      end
    end

  end
end
