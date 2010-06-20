require 'spec_helper'

module Chingu

  describe GameObject do
    
    before(:all) do 
      @game = Chingu::Window.new
    end

    it { should respond_to(:x) }
    it { should respond_to(:y) }
    it { should respond_to(:angle) }
    it { should respond_to(:center_x) }
    it { should respond_to(:center_y) }
    it { should respond_to(:factor_x) }
    it { should respond_to(:factor_y) }
    it { should respond_to(:zorder) }
    it { should respond_to(:mode) }
    it { should respond_to(:color) }

    describe "GameObject" do
      before do
        subject { GameObject.new }
      end
      
      it "should return certain default values after creation" do 
        angle.should eql(0)
      end
    end
    
    after(:all) do
      $window.close
    end
    
  end

end
