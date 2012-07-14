#Added button functinality
#Copyright 2012, neochuky neochuki@gmail.com
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
  #
  # PressButton provides a Qt like interface, a normal use would be
  #
  # myButton = PressButton(:x => x, :y => y,:button_image => image when the button
  # is not clicked,:pressed_image => image when the button is clicked )
  #
  # myButton.on_click do
  #   do some awesome
  # end
  #  
  #
  
  class PressButton < Chingu::GameObject
   alias :old_x=  :x=
   alias :old_y= :y= 
   
   def initialize(options =  {})
     super 
     #Get the button image
     if options[:button_image]
      @button_image = Image[options[:button_image]]
     else
      #Get the button animation
      if options[:button_animation]
        @animation = Animation.new(:file => options[:button_animation], 
        :size => options[:size]||[50,50], :delay => options[:delay]||100)
        @button_image = @animation.first
      else
        raise "A button needs an image or an animation\n"
      end    
     end   
     @x = options[:x]
     @y = options[:y]
      #Set event methods to nill 
      @on_click_method = @on_release_method  = @on_hold_method  = Proc.new {}
      #The button starts unpressed
      @clicked = false
      #The button can be used/clicked
      @active = true
      @image = @button_image
      @half_width = @button_image.width / 2 
      @half_height = @button_image.height / 2 
      #Total area of the button
      @button_range = {:x => ((self.x - @half_width)..(self.x + @button_image.width - @half_width)),
      :y => ((self.y - @half_height)..(self.y + @button_image.height - @half_height))}
      #If the user clicks, we check if he clicked a button
      self.input = {:left_mouse_button => :check_click,
        :released_left_mouse_button => :check_release,
        :holding_left_mouse_button => :check_hold }
      @initialized = true
   end 
 
    def active= value
      @active = value
    end 
    
   def active? value
      return @active
    end
    
     def check_click
        #If mouse position is inside the range, then go to click
        if @active and  
           @button_range[:x].include? $window.mouse_x and
           @button_range[:y].include? $window.mouse_y then
           #The user clicked on this button
           @clicked = true
           self.on_click
        end
     end 
     
    def check_hold
      if @active and 
        @button_range[:x].include? $window.mouse_x and 
        @button_range[:y].include? $window.mouse_y then
        self.on_hold
      end
    end 
     
    def check_release
      #If the button was pressed, it does not matter
      #where the user has the mouse
      if @active and @clicked then
        @clicked = false
        self.on_release
      end
    end 
     
    #Methods that allow QT like use. 
    def on_click(&block)
      if block_given?
        #If is first call, save the block that will be executed
        @on_click_method = block
      else
        #On a normal call, execute user's code
          @factor_x -= 0.02
          @factor_y -= 0.02
          @on_click_method.call
        end
      end 
       
       
      def on_release(&block)
        if block_given?
          @on_release_method = block
        else
          @factor_x += 0.02
          @factor_y += 0.02
          @on_release_method.call
        end
      end 
       
      def on_hold(&block)
        if block_given?
          @on_hold_method = block
        else
          @on_hold_method.call
        end
      end        
    
    def x= value
      @x = value
      old_x = value
      if @initialized
        @button_range[:x] = ((value - @half_width)..(value + @button_image.width - @half_width)) 
      end       
    end
    
    def y= value
      @y = value
      old_y = value
      if @initialized
        @button_range[:y] = ((value - @half_height)..(value + @button_image.height - @half_height))
      end       
    end      
    
    def update
      @image = @animation.next if @animation  
    end
  end  
end    