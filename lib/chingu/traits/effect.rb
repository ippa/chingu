#--
#
# Chingu -- Game framework built on top of the opengl accelerated gamelib Gosu
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
    module Effect
      #
      # Adds .rotating .fading and .zooming to any GameObject.
      #
      # TODO: better naming? suggestions:
      #
      # basic gosu unit <-> automation name
      # ==============================================
      # angle <-> rotation? rotating? automatic_angle?
      # factor <-> growth? scale? automatic_zoom?
      # alpha <-> fade
      #
      attr_accessor :rotating, :fading, :zooming
      
      #def self.initialize_trait(options)
      #  @effect_options = {:debug => false}.merge(options)
      #  puts "Effect#initialize"    if @effect_options[:debug]
      #  super
      #end
            
      #
      # Setup
      #
      def setup_trait(options)
        @effect_options = {:debug => false}.merge(options)
        puts "Effect#setup"     if @effect_options[:debug]
        
        @rotating = options[:rotating] || nil
        @zooming = options[:zooming] || nil
        @fading = options[:fading] || nil
        super
      end
      
      def draw
        puts "Effect#draw"      if @effect_options[:debug]
        super
      end
      
      def update
        puts "Effect#update"    if @effect_options[:debug]
        
        rotate(@rotating)    if @rotating
        fade(@fading)        if @fading
        zoom(@zooming)       if @zooming
        super
      end
      
      # Zoom - increase @factor_x and @factor_y at the same time.
      def zoom(amount = 0.1)
        @factor_x += amount
        @factor_y += amount
      end
          
      # Zoom Out - decrease @factor_x and @factor_y at the same time.
      def zoom_out(amount = 0.1)
        @factor_x -= amount
        @factor_y -= amount
      end
    
      # Rotate object 'amount' degrees
      def rotate(amount = 1)
        @angle += amount
      end
  
      # Fade object by decreasing/increasing color.alpha
      def fade(amount = 1)
        return if amount == 0
            
        new_alpha = @color.alpha + amount
        if amount < 0
          @color.alpha =  [0, new_alpha].max
        else
          @color.alpha =  [0, new_alpha].min
        end
      end

      # Fade out objects color by decreasing color.alpha
      def fade_out(amount = 1)
        fade(-amount)
      end

      # Fade in objects color by increasing color.alpha
      def fade_in(amount = 1)
        fade(amount)
      end
      
    end
  end
end