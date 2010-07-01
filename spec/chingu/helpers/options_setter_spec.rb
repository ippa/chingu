require 'spec_helper'

class Car < Struct.new(:speed, :angle)
  DEFAULTS = { :angle => 11, :speed => 22 }  
  include Chingu::Helpers::OptionsSetter
end


module Chingu
  module Helpers   
    describe OptionsSetter do
      
      describe "using without defaults" do
        before do
          @car = Car.new(:angle => 44)
        end

        it "should set angle from options" do
          @car.angle.should == 44
        end

        it "should set speed from defaults" do
          @car.speed.should == 22  
        end
      end
    end

  end
end
