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
  module AsyncOperations
    
    class Parallel < BasicOp
      
      undef :before
      undef :after
      
      def initialize
        @subtasks = []
      end
      
      def finished?
        @subtasks.empty? or @subtasks.all? &:finished?
      end
      
      def started?
        # Shortcut: if the first task has been started, then all tasks must
        # have been started.
        @subtasks.first.started?
      end
      
      def start
        @subtasks.each &:start
      end
      
      def update
        @subtasks.each &:update
      end
      
      def finish(*args)
        @subtasks.each &:finish
      end
      
    end
    
  end
end
