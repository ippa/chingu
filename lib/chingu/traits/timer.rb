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
    # A chingu trait providing timer-methods to its includer, examples:
    #   during(300) { @color = Color.new(0xFFFFFFFF) }   # forces @color to white ever update for 300 ms
    #   after(400) { self.destroy! }                     # destroy object after 400 ms
    #   between(1000,2000) { self.rotate(10) }           # starting after 1 second, call rotate(10) each update during 1 second
    #
    # All the above can be combined with a 'then { do_something }'. For example, a classic shmup damage effect:
    #   during(100) { @color.alpha = 100 }.then { @color.alpha = 255 }
    #
    module Timer 
      def setup_trait(options)
        @timer_options = {:debug => false}.merge(options)        
        
        #
        # Timers are saved as an array of arrays where each entry contains:
        # [start_time, end_time (or nil if one-shot), repeat-bool, &block]
        #
        @_timers = Array.new
        @_repeating_timers = Array.new
        super
      end

      def during(time, &block)
        ms = Gosu::milliseconds()
        @_last_timer = [ms, ms + time, block]
        @_timers << @_last_timer
        self
      end
      
      def after(time, &block)
        ms = Gosu::milliseconds()
        @_last_timer = [ms + time, nil, block]
        @_timers << @_last_timer
        self
      end
      
      def between(start_time, end_time, &block)
        ms = Gosu::milliseconds()
        @_last_timer = [ms + start_time, ms + end_time, block]
        @_timers << @_last_timer
        self
      end

      def every(delay, &block)
        ms = Gosu::milliseconds()
        @_repeating_timers << [ms + delay, delay, block]
      end

      def then(&block)
        # ...use one-shots start_time for our trailing "then".
        # ...use durable timers end_time for our trailing "then".
        start_time = @_last_timer[1].nil? ? @_last_timer[0] : @_last_timer[1]
        @_timers << [start_time, nil, false, block]
      end
      
      def update_trait
        ms = Gosu::milliseconds()
        @_timers.each do |start_time, end_time, block|
          block.call  if ms > start_time && (end_time == nil || ms < end_time)
        end
        
        
        index = 0
        @_repeating_timers.each do |start_time, delay, block|
          if ms > start_time
            block.call  
            @_repeating_timers[index] = [ms + delay, delay, block]
          end
          index += 1
        end

        # Remove one-shot timers (only a start_time, no end_time) and all timers which have expired
        @_timers.reject! { |start_time, end_time, block| (ms > start_time && end_time == nil) || (end_time != nil && ms > end_time) }
      
        super
      end
      
    end
  end
end