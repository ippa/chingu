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
    # Adds methods:
    #   rotate(amount)  # modifies @angle
    #   scale(amount)   # modifies @factor_x and @factor_y
    #   fade(amount)    # modifies @color.alpha
    # 
    # Also adds attributes
    #   rotation_rate = amount   # adds amount to @angle each game loop
    #   scale_rate = amount      # adds amount to @factor_x and @factor_y each game loop
    #   fade_rate = amount       # adds amount to @color.alpha each game loop
    #
    #
    # WARNING, I'm very close to deprecating this trait, it doesn't do much and still introduces new names to learn.
    # After a long discussion in #gosu I feel it's just better to use the accessors angle=, alpha= and factor=
    #  
    # BasicGameObject#alpha= contains the most important logic this trait had now anyhow.
    #

    module Effect
      attr_accessor :rotation_rate, :fade_rate, :scale_rate
                        
      #
      # Setup
      #
      def setup_trait(options)        
        @rotation_rate = options[:rotation_rate] || nil
        @scale_rate = options[:scale_rate] || nil
        @fade_rate = options[:fade_rate] || nil
        super
      end
      
      def draw_trait
        super
      end
      
      def update_trait        
        rotate(@rotation_rate)  if @rotation_rate
        fade(@fade_rate)        if @fade_rate
        scale(@scale_rate)      if @scale_rate
        super
      end
      
      # Increase @factor_x and @factor_y at the same time.
      def scale(amount = 0.1)
        @factor_x += amount
        @factor_y += amount
      end
      alias :zoom :scale
          
      # Ddecrease @factor_x and @factor_y at the same time.
      def scale_out(amount = 0.1)
        @factor_x -= amount
        @factor_y -= amount
      end
      alias :zoom_out :scale_out
      
      # Rotate object 'amount' degrees
      def rotate(amount = 1)
        self.angle += amount
      end
  
      # Fade object by decreasing/increasing color.alpha
      def fade(amount = 1)
        return if amount == 0
        self.alpha += amount
      end

      # Fade out objects color by decreasing color.alpha
      def fade_out(amount = 1)
        self.alpha -= amount
      end

      # Fade in objects color by increasing color.alpha
      def fade_in(amount = 1)
        self.alpha += amount
      end
      
    end
  end
end