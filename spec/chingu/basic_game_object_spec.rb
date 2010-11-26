require 'spec_helper'

class MyBasicGameObject < Chingu::BasicGameObject
end

module Chingu

  describe BasicGameObject do
    before :each do
      @game = Chingu::Window.new      
    end
    
    after :each do
      @game.close
    end

    it { should respond_to(:options) }
    it { should respond_to(:paused) }
    it { should respond_to(:visible) }
    it { should respond_to(:setup_trait) }
    it { should respond_to(:setup) }
    it { should respond_to(:update_trait) }
    it { should respond_to(:draw_trait) }

    context "An class inherited from BasicGameObject" do
      if "should keep track of its instances in class#all"
        3.times { MyBasicGameObject.create }
        MyBasicGameObject.all.count.should == 3
      end
    end
    
    context "when created with defaults in Chingu::Window" do
      it "should belong to main window it not created inside a game state" do
        subject.parent.should == @game
      end
    end
    
    context "when created in Chingu::GameState" do
      
    end
    
  end
end