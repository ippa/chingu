require 'spec_helper'

module Chingu

  describe "Console" do
    before :each do
      @console = Chingu::Console.new
    end
    
    it { @console.should respond_to :start }
    it { @console.should respond_to :fps }
    it { @console.should respond_to :update }
    it { @console.should respond_to :root }
    it { @console.should respond_to :game_state_manager }
    it { @console.should respond_to :root }
    it { @console.should respond_to :milliseconds_since_last_tick }
        
    context "a new Chingu::Console" do
      
      it "should return itself as current scope" do
        @console.current_scope.should == @console
      end
      
      it "should have 0 game objects" do
        @console.game_objects.size.should == 0
      end
    end
    
    context "each game iteration" do
      
      it "@console.update() should call update() on all unpaused game objects" do
        GameObject.create.should_receive(:update)
        GameObject.create(:paused => true).should_not_receive(:update)
        @console.update
      end

      it "should increment $window.ticks" do
        @console.ticks.should == 0
        @console.update
        @console.ticks.should == 1
        @console.update
        @console.ticks.should == 2
      end
      
    end
  end
end
