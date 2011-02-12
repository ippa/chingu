require 'weakref'

module Chingu
  module Instructions
    
    class BasicInstruction
      
      def initialize owner, &callback
        @owner    = WeakRef.new owner
        @callback = callback
        @finished = @started = false
      end
      
      #
      # Returns true if the instruction has finished executing. The meaning of
      # "finished" is determined by the particular subclass.
      #
      def finished?
        !!@finished
      end
      
      #
      # Returns true if the instruction has begun being processed.
      #
      def started?
        !!@started
      end
      
      def start;
        @started = true
      end
      
      def update; end
      
      def finish *args
        @callback[*args] if @callback
        @finished = true
      end
      
    end
    
  end
end