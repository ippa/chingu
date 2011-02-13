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

require "#{CHINGU_ROOT}/chingu/async_tasks/tween"

module Chingu
  module AsyncTasks
    
    # 
    # Syntactic sugar for tween(duration, :x => x, :y => y, :angle => angle)
    # 
    class Move < Tween
      
      def initialize(owner, duration, x, y, angle = nil)
        properties = { }
        
        properties[:x]     = x unless x.nil?
        properties[:y]     = y unless y.nil?
        properties[:angle] = angle unless angle.nil?
        
        super(duration, properties)
      end
      
    end
    
  end
end
