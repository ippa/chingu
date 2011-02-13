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

require 'weakref'

module Chingu
  module AsyncTasks
    
    class BasicTask
      
      attr_accessor :owner
      
      def initialize
        @state = nil
      end
      
      def owner
        if WeakRef === @owner
          @owner.__getobj__
        else
          @owner
        end
      end
      
      def owner=(new_owner)
        @owner = WeakRef.new(new_owner)
      rescue
        @owner = new_owner
      end
      
      #
      # Registers a block to be called when the task begins.
      # When called without a block, returns a previously registered block.
      #
      def before(&block)
        if block_given?
          @before = block
        else
          @before
        end
      end
      
      #
      # Registers a block to be called when the task finishes.
      # When called without a block, returns a previously registered block.
      #
      def after(&block)
        if block_given?
          @after = block
        else
          @after
        end
      end
      
      #
      # Returns true if the task has finished executing. The meaning of
      # "finished" is determined by the particular subclass.
      #
      def finished?
        @state == :finished
      end
      
      #
      # Returns true if the task has begun being processed.
      #
      def started?
        @state == :started || @state == :finished
      end
      
      def start
        @state = :started
        @before[] if @before
      end
      
      def update
      end
      
      def finish(*args)
        @after[*args] if @after
        @state = :finished
      end
      
    end
    
  end
end
