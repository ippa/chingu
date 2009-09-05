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
        end
      end
      
      #
      # Setup
      #
      def setup(parent_instance, options)
        @parent_instance = parent_instance
        @parent_instance.instance_eval do
          @velocity_x = options[:velocity_x] || nil
          @velocity_y = options[:velocity_y] || nil
          @acceleration_x = options[:acceleration_x] || nil
          @acceleration_y = options[:acceleration_y] || nil
          @max_velocity = options[:max_velocity] || nil
        end
      end
      
      #
      # Modifies X & Y of parent
      #
      def update(parent)
        #
        # acceleration/velocity logic (make use of $window.dt)
        #
      end
    end
  end
end