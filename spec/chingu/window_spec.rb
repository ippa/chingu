# frozen_string_literal: true

require 'spec_helper'

module Chingu
  # FIXME: Using let would be ideal, however the three first tests of context
  #        'each window iteration' fail
  describe 'Window' do
    before do
      @window = Chingu::Window.new
    end

    after :each do
      @window.close
    end

    it { @window.should respond_to :close }
    it { @window.should respond_to :fps }
    it { @window.should respond_to :update }
    it { @window.should respond_to :draw }
    it { @window.should respond_to :root }
    it { @window.should respond_to :game_state_manager }
    it { @window.should respond_to :factor }
    it { @window.should respond_to :cursor }
    it { @window.should respond_to :root }
    it { @window.should respond_to :milliseconds_since_last_tick }

    context 'a new Chingu::Window' do
      it 'should return itself as current scope' do
        @window.current_scope.should == @window
      end

      it 'should have 0 game objects' do
        @window.game_objects.size.should == 0
      end
    end

    context 'each game iteration' do
      it '$window.update() should call update() on all unpaused game objects' do
        GameObject.create.should_receive(:update)
        GameObject.create(paused: true).should_not_receive(:update)
        @window.update
      end

      it '$window.draw() should call draw() on all visible game objects' do
        GameObject.create.should_receive(:draw)
        @window.draw
      end

      it '$window.draw() should not call draw() on invisible game objects' do
        GameObject.create(visible: false).should_not_receive(:draw)
        @window.game_objects.first.visible?.should
        @window.draw
      end

      it 'should increment $window.ticks' do
        @window.ticks.should
        @window.update
        @window.ticks.should == 1
      end
    end
  end
end
