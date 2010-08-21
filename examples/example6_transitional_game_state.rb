#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu

#
# Example of using a special GameState to fade between game states
#
# Using a simple game state, Chingu::GameStates::FadeTo, shipped with Chingu.
#
class Game < Chingu::Window
  def initialize
    super(640,800)
    switch_game_state(State1)
    self.input = {:space => :push, :return => :switch, :esc => :exit}
    self.caption = "Example of transitional game state FadeTo when switchin between two game states"
    transitional_game_state(Chingu::GameStates::FadeTo, {:speed => 5, :debug => true})
  end
  
  def push
    #
    # Since we have a transitional game state set, the bellow code in practice become:
    #
    # if current_game_state.is_a?(State1)
    #   push_game_state(Chingu::GameStates::FadeTo.new(State2.new, :speed => 10))
    # elsif current_game_state.is_a?(State2)
    #   push_game_state(Chingu::GameStates::FadeTo.new(State1.new, :speed => 10))
    # end    
    #
    if current_game_state.is_a?(State1)
      push_game_state(State2.new)
    elsif current_game_state.is_a?(State2)
      push_game_state(State1.new)
    end
  end
  
  def switch
    if current_game_state.is_a?(State1)
      switch_game_state(State2.new)
    elsif current_game_state.is_a?(State2)
      switch_game_state(State1.new)
    end
  end
end

class State1 < Chingu::GameState
  
  #
  # This is another way of achieving the same thing as the out-commeted draw-code
  # Since .create is used, it's automatically updated and drawn
  #
  def initialize(options = {})
    super
    Chingu::GameObject.create(:image => "ruby.png", :rotation_center => :top_left)
  end
  
  #def draw
  #  Image["ruby.png"].draw(0,0,0)
  #end  
end

class State2 < Chingu::GameState 
  def draw
    Image["video_games.png"].draw(0,0,0)
  end
end

Game.new.show