#
# Our basic particle class
#
include Chingu
module Chingu
  class Particle < Chingu::GameObject
    
    def initialize(options)
      super({:mode => :additive}.merge(options))
        
      @rotation = options[:rotation] || 0
      @zoom = options[:zoom] || 0
      @fade = options[:fade] || 0
      
      @width = options[:width]
      @height = options[:width]
  
      if options[:animation].is_a? String
        @animation = Animation.new(:file => media_path(options[:animation]), :width => @width, :height => @height)
      elsif options[:animation].is_a? Animation
        @animation = options[:animation]
      end
    end
      
    def update(time)
      self.image = @animation.next!   if @animation
      self.rotate(@rotation)
      self.zoom(@zoom)
      self.fade(@fade)
    end
    
  end
end