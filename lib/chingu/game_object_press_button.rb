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
  # myButton = PressButton(:x => x, :y => y,:released_image => image when the button
  # is not clicked,:pressed_image => image when the button is clicked )
  #
  # myButton.on_click do
  #   do some awesome
  # end
  #  
  #
  
  class PressButton < Chingu::GameObject
    
   def initialize(options =  {})
     #Normaly a button has two images, pressed and released
     @released_image = Image[options[:released_image]]
     @pressed_image = Image[options[:pressed_image]]
     super
   end 
     
    def setup
      #Set event methods to nill 
      @on_click_method = @on_release_method  = @on_hold_method  = Proc.new {}
      #The button starts unpressed
      @clicked = false
      @image = @released_image
      half_width = self.width / 2 
      half_height = self.height / 2 
      #Total area of the button
      @button_range = {:x => ((self.x - half_width)..(self.x + self.width - half_width)),
        :y => ((self.y - half_height)..(self.y + self.height - half_height))}
      #If the user clicks, we check if he clicked a button
      self.input = {:left_mouse_button => :check_click,
        :released_left_mouse_button => :check_release,
        :holding_left_mouse_button => :check_hold }
    end
    
     def check_click
        #If mouse position is inside the range, then go to click
        if @button_range[:x].include? $window.mouse_x and
           @button_range[:y].include? $window.mouse_y then
           #The user clicked on this button
           @clicked = true
           self.on_click
        end
     end 
     
    def check_hold
      if @button_range[:x].include? $window.mouse_x and 
        @button_range[:y].include? $window.mouse_y then
        self.on_hold
      end
    end 
     
    def check_release
      #If the button was pressed, it does not matter
      #where the user has the mouse
      if @clicked then
        @clicked = false
        self.on_release
      end
    end 
     
    #Methods that allow QT like use. 
    def on_click(&block)
      #Set pressed image
      if block_given?
        #If is first call, save the block that will be executed
        @on_click_method = block
      else
        #On a normal call, execute user's code
          @image = @pressed_image
          @on_click_method.call
        end
      end 
       
       
      def on_release(&block)
        if block_given?
          @on_release_method = block
        else
          @image = @released_image
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
    end
end  