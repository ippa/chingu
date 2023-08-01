# frozen_string_literal: true

require 'spec_helper'

class MyBasicGameObject < Chingu::BasicGameObject
end

class MyBasicGameObject2 < Chingu::BasicGameObject
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

    context 'A class inherited from BasicGameObject using classmethod create' do
      it 'should be automatically stored in $window.game_objects' do
        MyBasicGameObject.instances = []
        3.times { MyBasicGameObject.create }
        expect($window.game_objects.size).to eq(3)
      end

      it 'should have $window as parent' do
        go = MyBasicGameObject.create
        expect(go.parent).to eq($window)
      end

      it 'should keep track of its instances in class#all' do
        MyBasicGameObject.instances = []
        3.times { MyBasicGameObject.create }
        #
        # Can/should we remove the dependency on #update here before the created objects gets saved?
        # We mostly protect against adding to the object array while iterating over it
        #
        expect(MyBasicGameObject.all.size).to eq(3)
        expect(MyBasicGameObject.size).to eq(3)
      end

      it 'should be removed from game_objects list when destroy() is called' do
        MyBasicGameObject.instances = []
        go = MyBasicGameObject.create
        expect($window.game_objects.size).to eq(1)

        go.destroy
        expect($window.game_objects.size).to eq(0)
      end

      it 'should have all internal list cleared with classmethod destroy_all()' do
        MyBasicGameObject.instances = []
        3.times { MyBasicGameObject.create }
        MyBasicGameObject.destroy_all

        expect(MyBasicGameObject.size).to eq(0)
      end

      it 'should have all instances removed from parent-list with classmethod destroy_all()' do
        MyBasicGameObject.instances = []
        3.times { MyBasicGameObject.create }
        MyBasicGameObject.destroy_all

        expect($window.game_objects.size).to eq(0)
      end
    end

    context 'A class inherited from BasicGameObject' do
      it 'should return empty array on classmethod all() if no objects have been created' do
        # Only place MyBasicGameObject2 is used
        expect(MyBasicGameObject2.all).to eq([]) # Surely there's a better way
      end

      it 'should take hash-argument, parse it and save in options' do
        MyBasicGameObject.instances = []
        game_object = MyBasicGameObject.new(paused: false, foo: :bar)
        expect(game_object.paused?).to be(false)
        expect(game_object.options).to eq({ paused: false, foo: :bar })
      end

      it 'should call setup() at the end of initialization' do
        game_object = MyBasicGameObjectWithSetup.new(paused: false)
        expect(game_object.paused?).to be(true)
      end

      it 'should be unpaused by default' do
        expect(subject.paused?).to be(false)
      end

      it 'should change paused status with pause()/unpause()' do
        subject.pause
        expect(subject.paused?).to be(true)
        subject.unpause
        expect(subject.paused?).to be(false)
      end

      it 'should give a well named string with filename()' do
        expect(MyBasicGameObject.new.filename).to eq('my_basic_game_object')
      end
    end

    context 'when created with defaults in Chingu::Window' do
      it 'should belong to main window it not created inside a game state' do
        expect(subject.parent).to eq(@game)
      end
    end

    context 'when created in Chingu::GameState' do
      # TODO
    end
  end
end
