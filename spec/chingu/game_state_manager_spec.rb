require 'spec_helper'

module Chingu
  describe GameStateManager do  
    before :each do
      @game = Chingu::Window.new      
    end

    after :each do
      @game.close
    end
    
    describe "initial configuration" do
      it "$window should have a game_state_manager" do
        @game.game_state_manager.should_not be_nil
      end
      it "should have 0 game states" do
        @game.game_state_manager.game_states.count.should == 0
      end
    end
  
    describe "push_game_state" do
      before :each do
        @game.push_game_state(Chingu::GameStates::Pause)
        @game.push_game_state(Chingu::GameStates::Edit)        
      end
      
      it "should change current game state" do
        @game.current_game_state.class.should == Chingu::GameStates::Edit
      end
            
      it "should keep last game state" do
        @game.game_state_manager.previous_game_state.class.should == Chingu::GameStates::Pause        
        @game.current_game_state.class.should == Chingu::GameStates::Edit
      end
      
      it "should increment total # of game states" do
        @game.game_states.count.should == 2
      end
      
    end

    describe "pop_game_state" do
      before :each do
        @game.push_game_state(Chingu::GameStates::Pause)
        @game.push_game_state(Chingu::GameStates::Edit)
      end
      
      it "should replace current game state with last one" do
        @game.pop_game_state
        @game.current_game_state.class.should == Chingu::GameStates::Pause
      end
      
      it "should decrement total # of game states" do
        @game.pop_game_state        
        @game.game_states.count.should == 1
      end
    end

    describe "switch_game_state" do
      before :each do
        @game.push_game_state(Chingu::GameStates::Pause)
        @game.switch_game_state(Chingu::GameStates::Debug)
      end
      
      it "should replace current game state" do
        @game.current_game_state.should be_a Chingu::GameStates::Debug
      end
      
      it "should not change the total amount of game states" do
        @game.game_states.count.should == 1
      end
    end
    
    describe "pop_until_game_state" do
      before :each do
        @game.push_game_state(Chingu::GameStates::Pause)       
        @game.push_game_state(Chingu::GameStates::Debug)
        @game.push_game_state(Chingu::GameStates::Debug)
        @states = @game.game_state_manager.instance_variable_get(:@game_states).dup
      end
      
      describe "with class" do
        it "should finalize popped states" do
          @states[1].should_receive(:finalize)
          @states[2].should_receive(:finalize)
          @game.pop_until_game_state(Chingu::GameStates::Pause)
        end
        
        it "should setup revealed states" do
          @states[0].should_receive(:setup)
          @states[1].should_receive(:setup)
          @game.pop_until_game_state(Chingu::GameStates::Pause)          
        end
          
        it "should pop down to the given game state" do
          @game.pop_until_game_state(Chingu::GameStates::Pause)
          @game.game_states.should eq [@states[0]]
        end
      end
      
      describe "with instance" do
        it "should finalize popped states" do
          @states[1].should_receive(:finalize)
          @states[2].should_receive(:finalize)
          @game.pop_until_game_state(@states[0])          
        end
        
        it "should setup revealed states" do
          @states[0].should_receive(:setup)
          @states[1].should_receive(:setup)
          @game.pop_until_game_state(@states[0])          
        end
          
        it "should pop down to the given game state" do
          @game.pop_until_game_state(@states[0])
          @game.game_states.should eq [@states[0]]
        end
      end
    end
      
    describe "clear_game_states" do
      it "should clear all game states" do
        @game.push_game_state(Chingu::GameStates::Pause)
        @game.push_game_state(Chingu::GameStates::Edit)
        @game.clear_game_states
        @game.game_states.count.should == 0
      end
    end
    
    describe "transitional_game_state" do
      before :each do
        @game.transitional_game_state(Chingu::GameStates::FadeTo)
        @game.push_game_state(Chingu::GameStates::Pause)
        @game.push_game_state(Chingu::GameStates::Edit)
      end
      
      #it "should get back to the last game state after popping" do
      #  @game.pop_game_state
      #  @game.update
      #  sleep 4
      #  @game.update
      #  @game.current_game_state.class.should == Chingu::GameStates::Pause
      #end
      
      it "keep track of amount of created game states" do
        @game.game_states.count.should == 2
      end
    end
    
  end
end
