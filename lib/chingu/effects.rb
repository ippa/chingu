#
# Effect-class
#
module Chingu
  class Effect
    def initialize(options)
      super({:mode => :additive}.merge(options))
      @trail = options[:trail] || 10
    end
      
    def update(time)
    end    
  end
end