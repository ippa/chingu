module Chingu
  #
  # A game object class with most components included, nice for quick prototypes
  #
  class Actor < Chingu::GameObject
    has_traits :effect, :velocity, :input

    def update
      # needed for traits to work
      super     
      
      # your game logic Here
    end    
  end
end