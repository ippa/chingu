#--
#
# Chingu -- OpenGL accelerated 2D game framework for Ruby
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++

module Chingu
  module Async
    
    #
    # Implements a DSL for appending new instructions to an instruction queue.
    #
    class QueueBuilder
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
          klass = Chingu::AsyncOperations.const_get(klass_name)
          
          instruction = klass.new(@owner, *args, &block)
          
        when Chingu::AsyncOperations::BasicOp
          # pass
          
        else
          instruction = instruction.new(@owner, *args, &block)
          
        end
        
        @instructions.enq(instruction)
        instruction
      end
      
      #
      # Attempting to invoke a nonexistant method automatically calls
      # +instruct+ with the method name as the instruction type.
      #
      alias :method_missing :instruct
      
    end
    
  end
end
