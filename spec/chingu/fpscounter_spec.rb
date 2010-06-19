require 'spec_helper'

describe Chingu::FPSCounter do

  it { should respond_to(:fps) }
  it { should respond_to(:milliseconds_since_last_tick) }
  it { should respond_to(:ticks) }

  describe "#register_tick" do
    before do
      Gosu.stub(:milliseconds).and_return(1000)
      subject { Chingu::FPSCounter.new }
    end

    it "increases the tick counter" do
      expect {
        subject.register_tick
      }.to change(subject, :ticks).from(0).to(1)
    end

    it "keeps track of the fps" do
      subject.register_tick
      Gosu.stub(:milliseconds).and_return(1500)
      subject.register_tick
      Gosu.stub(:milliseconds).and_return(2000)
      subject.register_tick
      subject.fps.should eq 3 # #register_tick has been called 3 times within 1 second = 3 FPS
    end

    it "calculates how many milliseconds passed since last game loop iteration and returns that value" do
      Gosu.stub(:milliseconds).and_return(2000)
      subject.register_tick.should equal 1000
      subject.milliseconds_since_last_tick.should eql(1000) 
    end
    
  end

end
