require 'spec_helper'

module Chingu

  describe GameObjectList do
    before :each do
      @game = Chingu::Window.new
    end
    
    after :each do
      @game.close
    end
    
    it { should respond_to :draw }
    it { should respond_to :update }
    it { should respond_to :each }
    it { should respond_to :each_with_index }
    it { should respond_to :select }
    it { should respond_to :first }
    it { should respond_to :last }
    it { should respond_to :show }
    it { should respond_to :hide }
    it { should respond_to :pause }
    it { should respond_to :unpause}
    
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
      
      it "should call update() on all unpaused game objects" do
        GameObject.create.should_receive(:update)
        GameObject.create(:paused => true).should_not_receive(:update)
        @game.game_objects.update
      end

      it "should call draw() on all visible game objects" do
        GameObject.create.should_receive(:draw)
        GameObject.create(:visible => false).should_not_receive(:draw)
        @game.game_objects.draw
      end
      
      it "should call draw_relative() on all visible game objects" do
        GameObject.create.should_receive(:draw_relative)
        GameObject.create(:visible => false).should_not_receive(:draw_relative)
        @game.game_objects.draw_relative
      end
      
      it "should pause all game objects with pause!" do
        5.times { GameObject.create }
        @game.game_objects.pause!
        @game.game_objects.each do |game_object|
          game_object.paused.should == true
        end
      end
      
      it "should hide all game objects with hide!" do
        5.times { GameObject.create }
        @game.game_objects.hide!
        @game.game_objects.each do |game_object|
          game_object.visible.should == false
        end
      end
      
    end
  end
end
