require "spec_helper"

class InputClientTest
  include Chingu::Helpers::InputClient
end

class TestState < Chingu::GameState
end

module Chingu
  describe Chingu::Helpers::InputClient do
    before :each do
      $window = mock Gosu::Window
      $window.stub!(:button_down?).and_return(false)

      @subject = InputClientTest.new
      @subject.stub!(:handler1).and_return(nil)
      @handler1 = @subject.method :handler1
      @subject.stub!(:handler2).and_return(nil)
      @handler2 = @subject.method :handler2
    end

    describe "#holding?" do
      it "should be true if that key is being held down" do
        $window.should_receive(:button_down?).with(Gosu::KbSpace).and_return(true)
        @subject.holding?(:space).should be_true
      end

      it "should be false if that key is being held down" do
        $window.should_receive(:button_down?).with(Gosu::KbSpace).and_return(false)
        @subject.holding?(:space).should be_false
      end
    end

    describe "#holding_all?" do
      it "should be true if all of those keys are being held down" do
        $window.should_receive(:button_down?).with(Gosu::KbSpace).and_return(true)
        $window.should_receive(:button_down?).with(Gosu::KbA).and_return(true)
        @subject.holding_all?(:space, :a).should be_true
      end

      it "should be false if all of those keys are not being held down" do
        @subject.holding_all?(:space, :a).should be_false
      end

      it "should be false if some of those keys are not being held down" do
        $window.stub!(:button_down?).with(Gosu::KbSpace).and_return(true)
        @subject.holding_all?(:space, :a).should be_false
      end
    end

    describe "#holding_any?" do
      it "should be true if any of those keys are being held down" do
        $window.stub!(:button_down?).with(Gosu::KbA).and_return(true)
        $window.stub!(:button_down?).with(Gosu::KbSpace).and_return(true)
        @subject.holding_any?(:space, :a).should be_true
      end

      it "should be false if none of those keys are being held down" do
        @subject.holding_any?(:space, :a).should be_false
      end
    end

    describe "#input" do
      it "should initially be an empty hash" do
        @subject.input.should == {}
      end
    end

    describe "#input=" do
      it "should do stuff"
    end

    describe "#on_input" do
      it "should add a handler that is given as a block" do
        block = lambda { p "hello world" }
        lambda { @subject.on_input :a, &block }.should change(@subject, :input).from({}).to({:a => block})
      end

      it "should add a handler that is given as a method" do
        lambda { @subject.on_input :a, @handler1 }.should change(@subject, :input).from({}).to({:a => @handler1})
      end

      it "should add a handler that is given as a proc" do
        proc = lambda { puts "Hello" }
        lambda { @subject.on_input :a, proc }.should change(@subject, :input).from({}).to({:a => proc})
      end

      it "should add a handler that is given as a string or symbol" do
        [:handler1, "handler1"].each do |handler|
          @subject.instance_variable_set("@input", nil)
          lambda { @subject.on_input :a, handler }.should change(@subject, :input).from({}).to({:a => @handler1})
        end
      end

      it "should add a handler that is given as a Chingu::GameState class" do
        lambda { @subject.on_input :a, TestState }.should change(@subject, :input).from({}).to({:a => TestState})
      end

      it "should add a handler that is given as a Chingu::GameState instance" do
        state = TestState.new
        lambda { @subject.on_input :a, state }.should change(@subject, :input).from({}).to({:a => state})
      end

      it "should raise an error if given an unknown key" do
        lambda { @subject.on_input :aardvark, @handler1 }.should raise_error ArgumentError
      end

      it "should raise an error if given an incorrect action" do
        lambda { @subject.on_input :a, 47 }.should raise_error ArgumentError
      end

      it "should add a new handler if one already exists" do
        @subject.on_input :a, @handler1
        lambda { @subject.on_input :b, @handler2 }.should change(@subject, :input).from({:a => @handler1}).to({:a => @handler1,:b => @handler2})
      end

      it "should overwrite existing handlers" do
        @subject.on_input :a, @handler1
        lambda { @subject.on_input :a, @handler2 }.should change(@subject, :input).from({:a => @handler1}).to({:a => @handler2})
      end

      it "should consider all key synonyms the same" do
        @subject.on_input :left, @handler1
        lambda { @subject.on_input :left_arrow, @handler2 }.should change(@subject, :input).from({:left_arrow => @handler1}).to({:left_arrow => @handler2})
      end

      it "should split up and standardise key arrays" do
        lambda { @subject.on_input([:space, :left], @handler1) }.should change(@subject, :input).from({}).to({:" " => @handler1, :left_arrow => @handler1})
      end

      it "should raise an error if both an action and a hander are given" do
        block = lambda { p "hello world" }
        lambda { @subject.on_input :a, "Hello", &block }.should raise_error ArgumentError
      end
    end
  end
end