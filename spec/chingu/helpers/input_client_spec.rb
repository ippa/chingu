require "spec_helper"

module Chingu

  describe Helpers::InputClient do

    before :each do

      $window = double(Gosu::Window)
      $window.stub(:button_down?).and_return(false)

      @subject = Object.new.extend described_class
      @subject.stub(:handler1).and_return(nil)

      @handler1 = @subject.method :handler1

      @subject.stub(:handler2).and_return(nil)

      @handler2 = @subject.method :handler2


    end

    after :each do
      $window = nil
    end


    describe "#holding?" do

      it "should be true if that key is being held down" do
       $window.should_receive(:button_down?).with(Gosu::KbSpace).and_return(true)
        @subject.holding?(:space).should be_truthy
      end

      it "should be false if that key is being held down" do
        $window.should_receive(:button_down?).with(Gosu::KbSpace).and_return(false)
        @subject.holding?(:space).should be_falsey
      end
    end

    describe "#holding_all?" do
      it "should be true if all of those keys are being held down" do
        $window.should_receive(:button_down?).with(Gosu::KbSpace).and_return(true)
        $window.should_receive(:button_down?).with(Gosu::KbA).and_return(true)
        @subject.holding_all?(:space, :a).should be_truthy
      end

      it "should be false if all of those keys are not being held down" do
        @subject.holding_all?(:space, :a).should be_falsey
      end

      it "should be false if some of those keys are not being held down" do
        $window.stub(:button_down?).with(Gosu::KbSpace).and_return(true)
        @subject.holding_all?(:space, :a).should be_falsey
      end
    end

    describe "#holding_any?" do
      it "should be true if any of those keys are being held down" do
        $window.stub(:button_down?).with(Gosu::KbA).and_return(true)
        $window.stub(:button_down?).with(Gosu::KbSpace).and_return(true)
        @subject.holding_any?(:space, :a).should be_truthy
      end

      it "should be false if none of those keys are being held down" do
        @subject.holding_any?(:space, :a).should be_falsey
      end
    end

    describe "#input" do
      it "should initially be an empty hash" do
        @subject.input.should == {}
      end
    end

    describe "#input=" do
      it "should set the input hash" do
        @subject.input = { :a => GameStates::Pause, :b => GameState }
        @subject.input.should == { :a => [GameStates::Pause], :b => [GameState] }
      end

      it "should set the input array" do
        @subject.stub(:a)
        @subject.stub(:b)
        @subject.input = [:a, :b]
        @subject.input.should == { :a => [@subject.method(:a)], :b => [@subject.method(:b)] }
      end
    end

    describe "#add_inputs" do
      it "should set the input hash" do
        @subject.add_inputs :a => GameStates::Pause, :b => GameState
        @subject.input.should == { :a => [GameStates::Pause], :b => [GameState] }
      end

      it "should set the input array" do
        @subject.stub(:a)
        @subject.stub(:b)
        @subject.add_inputs :a, :b
        @subject.input.should == { :a => [@subject.method(:a)], :b => [@subject.method(:b)] }
      end

      # Not bothering with all the options, since it is tested fully, though indirectly, in #on_input already.
      # I suspect it might be better to put the logic in on_input rather than in input too. Mmm.
      it "should do other stuff"
    end

    describe "#on_input" do
      it "should add a handler that is given as a block" do
        block = lambda {}
        @subject.on_input :a, &block
        @subject.input.should == { :a => [block] }
      end

      it "should add a handler that is given as a method" do
        @subject.on_input :a, @handler1
        @subject.input.should == { :a => [@handler1] }
      end

      it "should add a handler that is given as a proc" do
        proc = lambda { puts "Hello" }
        @subject.on_input :a, proc
        @subject.input.should == { :a => [proc] }
      end

      [:handler1, "handler1"].each do |handler|
        it "should add a handler that is given as a #{handler.class}" do
          @subject.on_input :a, handler
          @subject.input.should == { :a => [@handler1] }
        end
      end

      it "should add multiple handlers for the same event" do
        @subject.on_input :a, @handler1
        @subject.on_input :a, @handler2
        @subject.input.should == { :a => [@handler1, @handler2] }
      end

      it "should automatically handle to a method if only the input is given" do
        @subject.stub(:a)
        @subject.on_input :a
        @subject.input.should == { :a => [@subject.method(:a)] }
      end

      it "should add multiple handlers for the same event, even if given different key names" do
        @subject.on_input :left, @handler1
        @subject.on_input :left_arrow, @handler2
        @subject.input.should == { :left_arrow => [@handler1, @handler2] }
      end

      it "should add a handler that is given as a Chingu::GameState class" do
        @subject.on_input :a, GameStates::Pause
        @subject.input.should == { :a => [GameStates::Pause] }
      end

      it "should add a handler that is given as a Chingu::GameState instance" do
        state = GameState.new
        @subject.on_input :a, state
        @subject.input.should == { :a => [state] }
      end

      it "should raise an error if given an unknown key" do
        lambda { @subject.on_input :aardvark, @handler1 }.should raise_error ArgumentError
      end

      it "should raise an error if given an incorrect action" do
        lambda { @subject.on_input :a, 47 }.should raise_error ArgumentError
      end

      it "should add a new handler if one already exists for that input" do
        @subject.on_input :a, @handler1
        @subject.on_input :b, @handler2
        @subject.input.should == { :a => [@handler1], :b => [@handler2] }
      end

      it "should consider all key synonyms the same" do
        @subject.on_input :left, @handler1
        @subject.on_input :left_arrow, @handler2
        @subject.input.should == { :left_arrow => [@handler1, @handler2] }
      end

      it "should split up and standardise key arrays" do
        @subject.on_input([:space, :left], @handler1)
        @subject.input.should == { :" " => [@handler1], :left_arrow => [@handler1] }
      end

      it "should raise an error if both an action and a hander are given" do
        block = lambda { p "hello world" }
        lambda { @subject.on_input :a, "Hello", &block }.should raise_error ArgumentError
      end
    end
  end
end
