module Chingu
  #
  # Various helper-methods to manipulate the screen
  #
  module GFXHelpers
    #
    # Fills whole window with color 'c'
    #
    def fill(color)
      $window.draw_quad(0, 0, color,
                        $window.width, 0, color,
                        $window.width, $window.height, color,
                        0, $window.height, color,
                        0, :default)
    end
     
    #
    # Fills a given Rect 'r' with color 'c'
    #
    def fill_rect(rect, color)
      rect = Rect.new(rect)     # Make sure it's a rect
      $window.draw_quad(  rect.x, rect.y, color,
                          rect.right, rect.y, color,
                          rect.right, rect.bottom, color,
                          rect.x, rect.bottom, color,
                          0, :default)
    end
    
    #
    #
    #
    def fill_gradient(options)
      default_options = {	:from => Gosu::Color.new(255,0,0,0),
													:to => Gosu::Color.new(255,255,255,255), 
													:thickness => 10, 
													:orientation => :vertical,
													:rect => Rect.new([0, 0, $window.width, $window.height])
												}
			options = default_options.merge(options)
      
      rect = Rect.new(options[:rect])
      
      if options[:orientation] == :vertical
        step = rect.height / options[:thickness]
        rect.height = step
      else
        step = rect.width / options[:thickness]
        rect.width = step
      end      
            
      color = Color.new(options[:from].alpha, options[:from].red, options[:from].green, options[:from].blue)
      red_step = (options[:to].red - options[:from].red) / options[:thickness]
      green_step = (options[:to].green - options[:from].green) / options[:thickness]
      blue_step = (options[:to].blue - options[:from].blue) / options[:thickness]
      counter = 0
      
      while counter < options[:thickness]
				if options[:orientation] == :vertical
          fill_rect(rect, color)
					rect.y += step
				else
          fill_rect(rect, color)
					rect.x += step
				end
				
        counter += 1
        color.red   = color.red + red_step
        color.blue  = color.blue + blue_step
        color.green = color.green + green_step
			end      
    end
  end
end