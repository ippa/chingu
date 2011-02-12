module Chingu
  module Instructable
    
    class InstructionQueue
      # extend Forwardable
      # def_delegator :@queue, :push,  :enq
      # def_delegator :@queue, :shift, :deq
      # def_delegator :@queue, :first, :front
      # def_delegator :@queue, :clear
      
      def initialize
        @queue = []
      end
      
      #
      # Processes the first instruction on the queue, each tick removing the
      # instruction once it has finished.
      #
      def update
        if instruction = front
          instruction.start unless instruction.started?
          instruction.update
          deq if instruction.finished?
          instruction
        end
      end
      
      def front
        @queue.first
      end
      
      def enq *instructions
        @queue.push *instructions
      end
      
      def deq
        @queue.shift
      end
      
      def clear
        @queue.clear
      end
      
    end
    
  end
end