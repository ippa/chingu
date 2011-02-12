require "#{CHINGU_ROOT}/chingu/async_operations/tween"

module Chingu
  module AsyncOperations
    
    # 
    # Syntactic sugar for tween(duration, :x => x, :y => y)
    # 
    class Move < Tween
      
      def initialize(owner, duration, x, y, &callback)
        super(owner, duration, :x => x, :y => y, &callback)
      end
      
    end
    
  end
end
