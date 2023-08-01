# frozen_string_literal: true

require 'spec_helper'

describe Chingu::Window do
  before do
    # FIXME: Using let would be ideal, however the three first tests of context
    #        'each window iteration' fail
    @window = Chingu::Window.new
  end

  after do
    @window.close
  end

  it { expect(@window).to respond_to(:close) }
  it { expect(@window).to respond_to(:fps) }
  it { expect(@window).to respond_to(:update) }
  it { expect(@window).to respond_to(:draw) }
  it { expect(@window).to respond_to(:root) }
  it { expect(@window).to respond_to(:game_state_manager) }
  it { expect(@window).to respond_to(:factor) }
  it { expect(@window).to respond_to(:cursor) }
  it { expect(@window).to respond_to(:root) }
  it { expect(@window).to respond_to(:milliseconds_since_last_tick) }

  context 'When initialized' do
    it 'returns itself as current scope' do
      expect(@window.current_scope).to eq(@window)
    end

    it 'has 0 game objects' do
      expect(@window.game_objects.size).to eq(0)
    end
  end

  context 'each game iteration' do
    # TODO: Maybe it'll be more useful to use $window instead of @window,
    #       as to check that chingu properly sets the global window

    it '$window.update() will call update() on all unpaused game objects' do
      expect(Chingu::GameObject.create).to receive(:update)
      expect(Chingu::GameObject.create(paused: true)).not_to receive(:update)

      @window.update
    end

    it '$window.draw() will call draw() on all visible game objects' do
      expect(Chingu::GameObject.create).to receive(:draw)

      @window.draw
    end

    it '$window.draw() will not call draw() on invisible game objects' do
      expect(Chingu::GameObject.create(visible: false)).not_to receive(:draw)

      expect(@window.game_objects.first.visible?).to be_falsy
      @window.draw
    end

    it 'increments $window.ticks' do
      expect(@window.ticks).to eq(0)

      @window.update

      expect(@window.ticks).to eq(1)
    end
  end
end
