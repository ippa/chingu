require 'spec_helper'

module Chingu

  describe GameObjectList do
    before :each do
      @game = Chingu::Window.new      
    end
    
    after :each do
      @game.close
    end
    
    it "should initialize properly"
    it { should respond_to :draw }
    it { should respond_to :update }
    it { should respond_to :each }
    it { should respond_to :each_with_index }
    it { should respond_to :select }
            
    context "$window.game_objects" do
      it "Should return created game objects" do
        go1 = GameObject.create
        go2 = GameObject.create
        @game.game_objects.first.should == go1
        @game.game_objects.last.should == go2
      end
      
      it "should be able to destroy game_objects while iterating" do
        10.times { GameObject.create }
        @game.game_objects.each_with_index do |game_object, index|
          game_object.destroy if index >= 5
        end
        @game.game_objects.size.should == 5
      end
    end
  end
end
