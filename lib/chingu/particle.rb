#
# Our basic particle class, basicly just a GameObject with trait "effect"
# 
# TODO: expand on this further, as it is now it doesn't add much.
#
module Chingu
  class Particle < Chingu::GameObject
    has_trait :effect
    
    def initialize(options)
      super({:mode => :additive}.merge(options))
      @animation = options[:animation] || nil      
    end
      
    def update
      super
      self.image = @animation.next!   if @animation
    end
    
  end
end