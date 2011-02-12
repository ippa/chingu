module Chingu
  module AsyncOperations
    
    #
    # Halts processing of instructions until the passed-in block returns a
    # true value, or the timeout expires. If no block is given, behaves as if
    # the block returned nil.
    #
    class Wait < BasicOp
      
      attr_accessor :timeout, :condition
      
      def initialize(owner, timeout = nil, &condition)
        super owner
        @age, @life = 0, timeout
        @condition  = condition
      end
      
      def update
        @age += $window.milliseconds_since_last_tick
        
        timed_out = (@life != nil) and (@age >= @life)
        result    = @condition and @condition[]
        
        finish(result) if result or timed_out
      end
      
    end
    
  end
end
