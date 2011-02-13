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
  module AsyncTasks
    
    #
    # Executes all subtasks in parallel.
    #
    class Parallel < Chingu::Async::BasicTask
      
      def initialize(&block)
        @subtasks = []
        
        # Make @subtasks behave like a TaskList for the TaskBuilder.
        # This is probably a dirty hack!
        class <<@subtasks
          alias :enq   :push
          alias :deq   :shift
          alias :front :first
        end
        
        add_tasks(&block)
      end
      
      def add_tasks(&block)
        builder = Chingu::Async::TaskBuilder.new(@subtasks)
        block[builder]
      end
      
      #
      # Returns true if all subtasks have finished executing.
      #
      def finished?
        @subtasks.empty? or @subtasks.all?(&:finished?)
      end
      
      def update(object)
        @subtasks.each { |task| task.update(object) }
      end
      
    end
    
  end
end
