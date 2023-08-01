# frozen_string_literal: true

require 'spec_helper'

module Chingu
  describe 'Console' do
    before :each do
      @console = Chingu::Console.new
    end

    after :each do
      $window = nil
    end

    it { expect(@console).to respond_to(:start) }
    it { expect(@console).to respond_to(:fps) }
    it { expect(@console).to respond_to(:update) }
    it { expect(@console).to respond_to(:root) }
    it { expect(@console).to respond_to(:game_state_manager) }
    it { expect(@console).to respond_to(:root) }
    it { expect(@console).to respond_to(:milliseconds_since_last_tick) }

    context 'a new Chingu::Console' do
      it 'should return itself as current scope' do
        expect(@console.current_scope).to eq(@console)
      end

      it 'should have 0 game objects' do
        expect(@console.game_objects.size).to eq(0)
      end
    end

    context 'each game iteration' do
      it '@console.update() should call update() on all unpaused game objects' do
        expect(GameObject.create).to receive(:update)
        expect(GameObject.create(paused: true)).not_to receive(:update)
        @console.update
      end

      it 'should increment $window.ticks' do
        expect(@console.ticks).to eq(0)
        @console.update
        expect(@console.ticks).to eq(1)
        @console.update
        expect(@console.ticks).to eq(2)
      end
    end
  end
end
