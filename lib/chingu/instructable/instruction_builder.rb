module Chingu
  module Instructable
    
    #
    # InstructionBuilder implements a DSL for appending new instructions to
    # an instruction queue.
    #
    class InstructionBuilder
      def initialize(owner, instructions)
        @owner, @instructions = owner, instructions
      end
      
      #
      # Add a new instruction to the queue. The first argument is a Symbol or
      # String naming the type of instruction; remaining arguments are passed
      # on to the instruction's constructor.
      # 
      # If a block is supplied, it is scheduled to be executed as soon as the
      # instruction is finished.
      #
      def instruct(instruction, *args, &block)
        case instruction
        when Symbol, String
          klass_name = Chingu::Inflector.camelize(instruction)
          klass = Chingu::Instructions.const_get(klass_name)
          klass.new(@owner, *args, &block)
        else
          instruction.new(@owner, *args, &block)
        end
      end
      
      #
      # Attempting to invoke a nonexistant method automatically calls
      # +instruct+ with the method name as the instruction type.
      #
      alias :method_missing :instruct
      
    end
    
  end
end