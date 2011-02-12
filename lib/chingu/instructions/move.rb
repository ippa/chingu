require "#{CHINGU_ROOT}/chingu/instructions/tween"

module Chingu
  module Instructions
    
    # 
    # Syntactic sugar for tween(duration, :x => x, :y => y)
    # 
    class Move < Tween
      
      def initialize(owner, duration, x, y, &callback)
        super owner, duration, :x => x, :y => y, &callback
      end
      
    end
    
  end
end
