module Chingu
  module Instructions
    
    #
    # Basic tweening for numerical properties.
    #
    # 	game_object.instruct do |q|
    # 	  q.tween 1000, :property => new_value
    # 	end
    #
    class Tween < BasicInstruction
      
      # TODO Tweening is pretty dumb...make it smarter.
      
      def initialize(owner, duration, properties, &callback)
        super owner, &callback
        @age, @life = 0, duration
        @properties = properties
      end
      
      def start
        super
        owner = @owner.__getobj__
        @properties.each do |name, value|
          @properties[name] = owner.send(name) .. value
        end
      end
      
      def update
        owner = @owner.__getobj__
        @age += $window.milliseconds_since_last_tick
        t = @age.to_f / @life
        t = 1.0 if t > 1
        @properties.each do |name, range|
          owner.send "#{name}=", range.interpolate(t)
        end
        finish if @age >= @life
      end
      
    end
    
  end
end
