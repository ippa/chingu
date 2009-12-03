require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

class Game < Chingu::Window
  def initialize
    super(640,400)
    self.input = {:esc => :exit}
    switch_game_state(Stuff)
  end
end

class Stuff < GameState
  has_trait :timer
  
  def initialize(options = {})
    super
    
    @thing = Thing.create(:x => $window.width/2, :y => $window.height / 2 )
    #every(1000) { Thing.create(:x => 200)}
    every(500){ @thing.visible? ? @thing.hide! : @thing.show!}
  end
  
  def update
    super
    game_objects.destroy_if { |object| object.outside_window? }
  end
end

class Thing < GameObject
  def initialize(options = {})
    super
    @image = Image["circle.png"]
  end
  
  def update
    #@y += 1
  end
end

Game.new.show