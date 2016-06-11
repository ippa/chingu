require "spec_helper"

describe Chingu::Helpers::InputDispatcher do
  before :each do
    @subject = Object.new.extend described_class
    @client = Object.new
  end

  it "should respond to methods" do
     @subject.should respond_to :input_clients
     @subject.should respond_to :add_input_client
     @subject.should respond_to :remove_input_client
  end

  {"button_down" => :a, "button_up" => :released_a}.each_pair do |event, key|
    describe "#dispatch_#{event}" do
      it "should dispatch key event if key is handled" do
        @client.should_receive(:handler).with(no_args)
        @client.stub(:input).with(no_args).and_return({ key => [@client.method(:handler)] })
        @subject.send("dispatch_#{event}", Gosu::KbA, @client)
      end

      it "should not dispatch key event if key is not handled" do
        @client.stub(:input).with(no_args).and_return({})
        @subject.send("dispatch_#{event}", Gosu::KbA, @client)
      end
    end
  end

  describe "#dispatch_input_for" do
    before :each do
      $window = double Chingu::Window
      $window.stub(:button_down?).and_return(false)
    end

    after :each do
      $window = nil
    end

    it "should dispatch if a key is being held" do
      @client.should_receive(:handler).with(no_args)
      $window.stub(:button_down?).with(Gosu::KbA).and_return(true)
      @client.stub(:input).with(no_args).and_return({:holding_a => [@client.method(:handler)]})
      @subject.dispatch_input_for(@client)
    end

    it "should do nothing if a key is not held" do
      @client.stub(:input).with(no_args).and_return({:holding_a => [lambda { raise "Shouldn't handle input!"}]})
      @subject.dispatch_input_for(@client)
    end
  end


  describe "#dispatch_actions" do
    it "should call a method" do
      @client.should_receive(:handler).with(no_args)
      @subject.send(:dispatch_actions, [@client.method(:handler)])
    end

    it "should call a proc" do
      @client.should_receive(:handler)
      @subject.send(:dispatch_actions, [lambda { @client.handler }])
    end

    it "should push a game-state instance" do
      state = Chingu::GameState.new
      @subject.should_receive(:push_game_state).with(state)
      @subject.send(:dispatch_actions, [state])
    end
    
    it "should push a game-state class" do
      @subject.should_receive(:push_game_state).with(Chingu::GameState)
      @subject.send(:dispatch_actions, [Chingu::GameState])
    end

    it "should call multiple actions if more have been set" do
      other = Object.new
      other.should_receive(:handler).with(no_args)
      @client.should_receive(:handler).with(no_args)
      @subject.send(:dispatch_actions, [@client.method(:handler), other.method(:handler)])
    end

    # Note, doesn't check if a passed class is incorrect. Life is too short.
    it "should raise an error with unexpected data" do
      lambda { @subject.send(:dispatch_actions, [12]) }.should raise_error ArgumentError
    end
  end
end