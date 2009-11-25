#
# Our basic particle class, basicly just a GameObject with trait "effect"
# 
# TODO: expand on this further, as it is now it doesn't add enough to warrant a whole new class.
#

module Chingu
  class Particle < Chingu::GameObject
    has_trait :effect
    
    def initialize(options)
      super({:mode => :additive}.merge(options))
      @animation = options[:animation] || nil      
    end
      
    def update
      self.image = @animation.next   if @animation
    end
    
  end
end