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
  module Traits
    
    #
    # A chingu trait providing an asynchronous operations queue
    #
    # For example:
    # 	class Robot < GameObject
    # 	  traits :asynchronous
    # 	  
    # 	  # robot stuff
    # 	end
    # 	
    # 	# later, controlling your robot...
    # 	robot.async do |q|
    # 	  q.tween(5000, :x => 1024, :y => 64) { robot.explode }
    # 	end
    #
    # Will move the robot asynchronously from its current location to
    # (1024, 64), then blow it up. The +async+ method returns immediately
    # after adding instructions to the queue.
    # 
    # The first operation on the queue is processed each tick during the
    # update phase, then removed from the queue when it is deemed finished.
    # What constitutes "finished" is determined by the particular subclass of
    # +BasicOp+.
    #
    
    module Asynchronous
      
      attr_reader :instructions
      
      #
      # Setup
      #
      def setup_trait(options)
        @instructions = Chingu::Async::OpQueue.new
        super
      end
      
      def update_trait
        @instructions.update
        super
      end
      
      #
      # Add a set of instructions to the instruction queue to be executed
      # asynchronously.
      #
      def async(*args, &block)
        if block_given?
          add_instruction_block *args, &block
        else
          add_instruction *args, &block 
        end
      end
      
      protected
      
      def add_instruction_block &block
        builder = Chingu::Async::QueueBuilder.new(self, @instructions)
        block[builder]
      end
      
      def add_instruction name, *args, &callback
        builder = Chingu::Async::QueueBuilder.new(self, @instructions)
        builder.instruct name, *args, &callback
      end
      
    end
  end
end
