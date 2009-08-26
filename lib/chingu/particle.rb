#
# Our basic particle class, from which we 
#
module Chingu
  class Particle < Chingu::GameObject
    def initialize(options)
      super({:mode => :additive}.merge(options))
        
      @rotation = options[:rotation] || 0
      @zoom = options[:zoom] || 0
      @fade = options[:fade] || 0
    end
      
    def update(time)
      @angle += @rotation
      self.zoom
    end
      
    def draw
    end
  end
end