#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu

#
# Using Chingus game state mananger in pure Gosu.
#
class Game < Gosu::Window
  attr_reader :font


  def initialize
    $window = super(800, 600, false)

    @font = Font.new($window, default_font_name(), 20)

    # Create our game state manager
    @manager = Chingu::GameStateManager.new

    # Switch to first state
    @manager.switch_game_state(State1)

    # The following *breaks* the code.  POP will not work reliably.
    # Insert FadeTo state between every push, pop and switch
    # @manager.transitional_game_state(Chingu::GameStates::FadeTo, :speed => 10, :game_state_manager => @manager)
  end


  def button_down(id)
    # This makes sure button_down(id) is called on the active game state
    # Enables input-handling in game states, you might wanna do the same with button_up()
    @manager.button_down(id)

    #if @manager.current_game_state.class != Chingu::GameStates::FadeTo

      case id

        when Button::Kb1
          @manager.push_game_state(State1)

        when Button::Kb2
          @manager.push_game_state(State2)

        when Button::Kb3
          @manager.push_game_state(State3)

        when Button::KbP
          Chingu::GameStates::Pause

        when Button::KbBackspace
          @manager.pop_game_state
      end

   # end

    exit if (id==Button::KbEscape)
  end


  def update
    # This makes sure update() is called on the active game state
    @manager.update
  end


  def draw
    @font.draw("Game State Stack. 1-3 to push a game state. Backspace to pop.", 100, 200, 0)
    @manager.game_states.each_with_index do |game_state, index|
      @font.draw("#{index+1}) #{game_state.to_s}", 100, 220+index*20, 0)
    end

    # This makes sure draw() is called on the active game state
    @manager.draw
  end
end

class State1 < Chingu::GameState
  def setup
    @spinner = ["|", "/", "-", "\\", "|", "/", "-", "\\"]
    @spinner_index = 0.0
  end


  def update
    @spinner_index += 0.1
    @spinner_index = 0 if @spinner_index >= @spinner.size
  end


  def draw
    $window.font.draw("Inside State1: #{@spinner[@spinner_index.to_i]}", 100, 100, 0)
  end
end

class State2 < Chingu::GameState
  def setup
    @factor = 0.0
    @ticks = 0.0
  end


  def update
    @ticks += 0.01
    @factor = 1.5 + Math.sin(@ticks).to_f
  end


  def draw
    $window.font.draw("Inside State2 - factor_y: #{@factor.to_s}", 100, 100, 0, 1.0, @factor)
  end
end


class State3 < Chingu::GameState
  def setup
    @factor = 0.0
    @ticks = 0.0
  end


  def update
    @ticks += 0.01
    @factor = 1.5 + Math.sin(@ticks).to_f
  end


  def draw
    $window.font.draw("Inside State3 - factor_x: #{@factor.to_s}", 100, 100, 0, @factor, 1.0)
  end
end


Game.new.show
