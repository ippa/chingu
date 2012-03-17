module Chingu
  #
  # GameObject inherits from BasicGameObject to get traits and some class-methods like .all and .destroy
  # On top of that, it encapsulates GOSUs Image#draw_rot and all its parameters.
  # In Chingu GameObject is a visual object, something to put on screen, centers around the .image-parameter.
  # If you wan't a invisible object but with traits, use BasicGameObject.
  #
class PressButton < GameObject
  def setup
        
    # @animations = Chingu::Animation.new(:file => "../media/heli.png")
    puts "press ejecuto"
    puts @animations
    #Set event methods to nill 
    @on_click_method = @on_release_method  = @on_hold_method  = Proc.new {}
    #Normaly a button has two images, pressed and unpressed
    @animations.frame_names =  {:scan => 0..1}
    #puts self.width
    #puts self.height
    @animation = @animations[:scan]
    #The button starts unpressed
    @image = @animation.first
    @clicked = false
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
=begin      
      puts $window.mouse_x
      puts $window.mouse_y
      puts self.center_x
      puts self.center_y
      puts self.center
      puts @button_range
=end
      #If mouse position is inside the range, then go to click
      if @button_range[:x].include? $window.mouse_x and
         @button_range[:y].include? $window.mouse_y then
         #The user clicked on this button
         @clicked = true
         self.on_click
      end
   end 
   
  def check_hold
=begin
  puts "holding"
  puts $window.mouse_x
  puts $window.mouse_y
  puts @button_range
=end
    if @button_range[:x].include? $window.mouse_x and 
      @button_range[:y].include? $window.mouse_y then
      self.on_hold
    end
  end 
   
  def check_release
=begin
    puts $window.mouse_x
    puts $window.mouse_y
    puts @button_range
=end
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
    @image = @animation.last
    if block_given?
      #If is first call, save the block that will be executed
      @on_click_method = block
    else
      #On a normal call, execute user's code
      @on_click_method.call
    end
  end 
   
   
  def on_release(&block)
    @image = @animation.first
    if block_given?
      @on_release_method = block
    else
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
