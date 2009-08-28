module Chingu
  #
  # Various helper-methods to manipulate the screen.
  # All drawings depend on the global variable $window which should be an instance of Gosu::Window or Chingu::Window
  #
  module GFXHelpers
  
    #
    # Fills whole window with color 'color'.
    #
    def fill(color)
      $window.draw_quad(0, 0, color,
                        $window.width, 0, color,
                        $window.width, $window.height, color,
                        0, $window.height, color,
                        0, :default)
    end
     
    #
    # Fills a given Rect 'rect' with Color 'color'
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
    # Fills window or a given rect with a gradient between two colors.
    #
    #   :from         - Start with this color
    #   :to           - End with this color
    #   :rect         - Only fill rectangle :rect with the gradient, either a Rect-instance or [x,y,width,height] Array.
    #   :orientation  - Either :vertical (top to bottom) or :horizontal (left to right)
    #
    def fill_gradient(options)
      default_options = { :from => Gosu::Color.new(255,0,0,0),
                          :to => Gosu::Color.new(255,255,255,255), 
                          :thickness => 10, 
                          :orientation => :vertical,
                          :rect => Rect.new([0, 0, $window.width, $window.height]),
                          :zorder => 0,
                          :mode => :default
                        }
			options = default_options.merge(options)
      rect = Rect.new(options[:rect])      
      if options[:orientation] == :vertical
        $window.draw_quad(  rect.x, rect.y, options[:from],
                            rect.right, rect.y, options[:from],
                            rect.right, rect.bottom, options[:to],
                            rect.x, rect.bottom, options[:to],
                            options[:zorder], options[:mode]
                          )
      else
        $window.draw_quad(  rect.x, rect.y, options[:from],
                            rect.x, rect.bottom, options[:from],
                            rect.right, rect.bottom, options[:to],
                            rect.right, rect.y, options[:to],
                            options[:zorder], options[:mode]
                          )        
      end
    end
  end
end