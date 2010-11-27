require 'spec_helper'

class MyBasicGameObject < Chingu::BasicGameObject
end

class MyBasicGameObjectWithSetup < Chingu::BasicGameObject
  def setup
    @paused = true
  end
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
    it { should respond_to(:setup_trait) }
    it { should respond_to(:setup) }
    it { should respond_to(:update_trait) }
    it { should respond_to(:draw_trait) }
    it { should respond_to(:filename) }

    context "A class inherited from BasicGameObject" do
      it "should be automatically stored in $window.game_objects" do
        3.times { go = MyBasicGameObject.create }
        $window.update
        $window.game_objects.size.should == 3
      end
      
      it "should have $window as parent" do
        go = MyBasicGameObject.create
        go.parent.should == $window
      end
      
      it "should keep track of its instances in class#all" do
        3.times { MyBasicGameObject.create }
        #
        # Can/should we remove the dependency on #update here before the created objects gets saved?
        # We mostly protect against adding to the object array while iterating over it
        #
        $window.update
        MyBasicGameObject.all.size.should == 3
        MyBasicGameObject.size.should == 3
      end
      
      it "should be removed from game_objects list when destroy() is called" do
        go = MyBasicGameObject.create
        $window.update
        $window.game_objects.size.should == 1
        go.destroy
        $window.update
        $window.game_objects.size.should == 0
      end

      it "should have all instances removed with classmethod #destroy_all()" do
        3.times { MyBasicGameObject.create }
        $window.update
        MyBasicGameObject.destroy_all
        $window.update
        $window.game_objects.size.should == 0
      end

      it "should take hash-argument, parse it and save in options" do
        game_object = MyBasicGameObject.new(:paused => false, :foo => :bar)
        game_object.paused?.should == false
        game_object.options.should == {:paused => false, :foo => :bar}
      end

      it "should call setup() at the end of initialization" do
        game_object = MyBasicGameObjectWithSetup.new(:paused => false)
        game_object.paused?.should == true
      end
      
      it "should be unpaused by default" do
        subject.paused?.should == false
      end
    
      it "should change paused status with pause()/unpause()" do
        subject.pause
        subject.paused?.should == true
        subject.unpause
        subject.paused?.should == false
      end
      
      it "should give a well named string with filename()" do
        MyBasicGameObject.new.filename.should == "my_basic_game_object"
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