require 'spec_helper'

module Chingu

  describe "Window" do
    before :each do
      @game = Chingu::Window.new      
    end
    
    after :each do
      @game.close
    end
    
    it { @game.should respond_to :close }
    it { @game.should respond_to :fps }
    it { @game.should respond_to :update }
    it { @game.should respond_to :draw }
    it { @game.should respond_to :root }
    it { @game.should respond_to :game_state_manager }
    it { @game.should respond_to :factor }
    it { @game.should respond_to :cursor }
    it { @game.should respond_to :root }
    it { @game.should respond_to :milliseconds_since_last_tick }
        
    context "a new Chingu::Window" do
      
      it "should return itself as current scope" do
        @game.current_scope.should == @game
      end
      
      it "should have 0 game objects" do
        @game.game_objects.size.should == 0
      end
    end
    
    context "each game iteration" do
      it "$window.update() should call update() on all unpaused game objects" do
        GameObject.create.should_receive(:update)
        GameObject.create(:paused => true).should_not_receive(:update)
        @game.update
      end
      
      it "$window.draw() should call draw() on all visible game objects" do
        GameObject.create.should_receive(:draw)
        @game.draw
      end
      
      it "$window.draw() should not call draw() on invisible game objects" do
        GameObject.create(:visible => false).should_not_receive(:draw)
        @game.game_objects.first.visible?.should == false
        @game.draw
      end
    end
  end
end
