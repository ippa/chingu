#
# Core extensions to GOSU
# Some of these require the gem 'texplay'
#
module Gosu
  
  class Image
    #
    # Returns true if the pixel at x, y is 100% transperant (good for collisiondetection)
    # Requires texplay
    #
    def transparent_pixel?(x, y)
      begin
        self.get_pixel(x,y)[3] == 0
      rescue
        puts "Error in get_pixel at x/y: #{x}/#{y}"
      end
    end
    
  end
end