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
    
    class TaskList
      # extend Forwardable
      # def_delegator :@queue, :push,  :enq
      # def_delegator :@queue, :shift, :deq
      # def_delegator :@queue, :first, :front
      # def_delegator :@queue, :clear
      
      def initialize
        @queue = []
      end
      
      #
      # Processes the first task on the queue, each tick removing the
      # task once it has finished.
      #
      def update(object)
        if task = front
          task.update object
          deq if task.finished?
          task
        end
      end
      
      def front
        @queue.first
      end
      
      def enq(*tasks)
        @queue.push(*tasks)
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
