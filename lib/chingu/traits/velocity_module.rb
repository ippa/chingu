module Chingu
  module Traits
    #
    # A chingu component providing velocity and acceleration logic. 
    #
    module Velocity
      attr_accessor :velocity_x, :velocity_y, :acceleration_x, :acceleration_y, :max_velocity
      
      def initialize(options)
        puts "Velocity#initialize"
        super
      end
      
      def stop
        @acceleration_y = @acceleration_x = @velocity_y = @acceleration_y = 0
      end
      
      #
      # Setup
      #
      def setup(options)
        puts "Velocity#setup"
        @velocity_x = options[:velocity_x] || 0
        @velocity_y = options[:velocity_y] || 0
        @acceleration_x = options[:acceleration_x] || 0
        @acceleration_y = options[:acceleration_y] || 0
        @max_velocity = options[:max_velocity] || 1000
        super
      end
      
      #
      # Modifies X & Y of parent
      #
      def update
        puts "Velocity#update"
        @velocity_y += @acceleration_y		if	(@velocity_y + @acceleration_y).abs < @max_velocity
        @velocity_x += @acceleration_x		if	(@velocity_x + @acceleration_x).abs < @max_velocity
        @y += @velocity_y
        @x += @velocity_x
        super
      end
    end
  end
end