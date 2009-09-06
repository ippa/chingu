module Chingu
  module Components
    #
    # A chingu component providing velocity and acceleration logic. 
    #
    class Velocity
      
      def initialize(parent_class, options)
        @parent_class = parent_class        
        @parent_class.class_eval do
          attr_accessor :velocity_x, :velocity_y, :acceleration_x, :acceleration_y, :max_velocity
          
          def stop
            @acceleration_y = @acceleration_x = @velocity_y = @acceleration_y = 0
          end
        end
      end
      
      #
      # Setup
      #
      def setup(parent_instance, options)
        @parent_instance = parent_instance
        @parent_instance.instance_eval do
          @velocity_x = options[:velocity_x] || 0
          @velocity_y = options[:velocity_y] || 0
          @acceleration_x = options[:acceleration_x] || 0
          @acceleration_y = options[:acceleration_y] || 0
          @max_velocity = options[:max_velocity] || 1000
        end
      end
      
      #
      # Modifies X & Y of parent
      #
      def update(parent)
        #
        # This is slower oddly enough?
        #
        #parent.velocity_y += parent.acceleration_y		if	(parent.velocity_y + parent.acceleration_y).abs < parent.max_velocity
        #parent.velocity_x += parent.acceleration_x		if	(parent.velocity_x + parent.acceleration_x).abs < parent.max_velocity
        #parent.y += parent.velocity_y
        #parent.x += parent.velocity_x
        
        parent.instance_eval do
          @velocity_y += @acceleration_y		if	(@velocity_y + @acceleration_y).abs < @max_velocity
          @velocity_x += @acceleration_x		if	(@velocity_x + @acceleration_x).abs < @max_velocity
          #vel_y = (@velocity_y + @acceleration_y).abs
          #@velocity_y = vel_y		if vel_y  < @max_velocity
          #vel_x = (@velocity_x + @acceleration_x).abs
          #@velocity_x  = vel_x  if vel_x  < @max_velocity
          
          @y += @velocity_y
          @x += @velocity_x
        end
      end
    end
  end
end