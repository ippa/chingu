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
    
    #
    # Halts processing of instructions until the passed-in block returns a
    # true value, or the timeout expires. If no block is given, behaves as if
    # the block returned nil.
    #
    class Wait < BasicOp
      
      attr_accessor :timeout, :condition
      
      def initialize(timeout = nil, &condition)
        super()
        @age, @life = 0, timeout
        @condition  = condition
      end
      
      def update
        @age += $window.milliseconds_since_last_tick
        
        timed_out = (@life != nil and @age >= @life)
        result    = (@condition and @condition[])
        
        finish(result) if result or timed_out
      end
      
    end
    
  end
end
