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
    # during(300) { @color = Color.new(0xFFFFFFFF) } # forces @color to white ever update for 300 ms
    # after(400) { self.destroy! } # destroy object after 400 ms
    # between(1000,2000) { self.rotate(10) } # starting after 1 second, call rotate(10) each update during 1 second
    #
    # All the above can be combined with a 'then { do_something }'. For example, a classic shmup damage effect:
    # during(100) { @color.alpha = 100 }.then { @color.alpha = 255 }
    #
    module Timer
    
      def setup_trait(options)
        #
        # Timers are saved as an array of arrays where each entry contains:
        # [name, start_time, end_time (or nil if one-shot), &block]
        #
        @_timers = Array.new
        @_repeating_timers = Array.new
        super
      end

      #
      # Executes block each update during 'time' milliseconds
      #
      def during(time, options = {}, &block)
        if options[:name]
          return if timer_exists?(options[:name]) && options[:preserve]
          stop_timer(options[:name])
        end

        ms = Gosu::milliseconds()
        @_last_timer = [options[:name], ms, ms + time, block]
        @_timers << @_last_timer
        self
      end
      
      #
      # Executes block after 'time' milliseconds
      #
      def after(time, options = {}, &block)
        if options[:name]
          return if timer_exists?(options[:name]) && options[:preserve]
          stop_timer(options[:name])
        end

        ms = Gosu::milliseconds()
        @_last_timer = [options[:name], ms + time, nil, block]
        @_timers << @_last_timer
        self
      end

      #
      # Executes block each update during 'start_time' and 'end_time'
      #
      def between(start_time, end_time, options = {}, &block)
        if options[:name]
          return if timer_exists?(options[:name]) && options[:preserve]
          stop_timer(options[:name])
        end

        ms = Gosu::milliseconds()
        @_last_timer = [options[:name], ms + start_time, ms + end_time, block]
        @_timers << @_last_timer
        self
      end

      #
      # Executes block every 'delay' milliseconds
      #
      def every(delay, options = {}, &block)
        if options[:name]
          return if timer_exists?(options[:name]) && options[:preserve]
          stop_timer(options[:name])
        end
        
        ms = Gosu::milliseconds()
        @_repeating_timers << [options[:name], ms + delay, delay, options[:during] ? ms + options[:during] : nil, block]
        if options[:during]
          @_last_timer = [options[:name], nil, ms + options[:during]]
          return self
        end
      end

      #
      # Executes block after the last timer ends
      # ...use one-shots start_time for our trailing "then".
      # ...use durable timers end_time for our trailing "then".
      #
      def then(&block)
        start_time = @_last_timer[2].nil? ? @_last_timer[1] : @_last_timer[2]
        @_timers << [@_last_timer[0], start_time, nil, block]
      end


      #
      # See if a timer with name 'name' exists
      #
      def timer_exists?(timer_name = nil)
        return false if timer_name.nil?
        @_timers.each { |name, | return true if timer_name == name }
        @_repeating_timers.each { |name, | return true if timer_name == name }
        return false
      end

      #
      # Stop timer with name 'name'
      #
      def stop_timer(timer_name)
        @_timers.reject! { |name, start_time, end_time, block| timer_name == name }
        @_repeating_timers.reject! { |name, start_time, end_time, block| timer_name == name }
      end
      
      #
      # Stop all timers
      #
      def stop_timers
        @_timers.clear
        @_repeating_timers.clear
      end
      
      def update_trait
        ms = Gosu::milliseconds()
        
        @_timers.each do |name, start_time, end_time, block|
          block.call if ms > start_time && (end_time == nil || ms < end_time)
        end
                
        index = 0
        @_repeating_timers.each do |name, start_time, delay, end_time, block|
          if ms > start_time
            block.call  
            @_repeating_timers[index] = [name, ms + delay, delay, end_time, block]
          end
          if end_time && ms > end_time
            @_repeating_timers.delete_at index
          else
            index += 1
          end
        end

        # Remove one-shot timers (only a start_time, no end_time) and all timers which have expired
        @_timers.reject! { |name, start_time, end_time, block| (ms > start_time && end_time == nil) || (end_time != nil && ms > end_time) }
      
        super
      end
      
    end
  end
end