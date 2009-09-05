#
# Our basic particle class
#
module Chingu
  class Particle < Chingu::GameObject
    add_component :effect
    
    def initialize(options)
      super({:mode => :additive}.merge(options))
      @rotation = options[:rotation] || 0
      @zoom = options[:zoom] || 0
      @fade = options[:fade] || 0
      @animation = options[:animation] || nil      
    end
      
    def update
      self.image = @animation.next!   if @animation
      self.rotate(@rotation)
      self.zoom(@zoom)
      self.fade(@fade)
    end
    
  end
end