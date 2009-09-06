module Chingu
  #
  # GameObject is our BasisGameObject (class with framespecific stuff)
  #
  # On top of that, it encapsulates GOSUs Image#draw_rot and all its parameters.
  #
  attr_accessor :image, :x, :y, :angle, :center_x, :center_y, :factor_x, :factor_y, :color, :mode, :zorder
  class GameObject < BasicGameObject
    
    def initialize(options = {})
      super

      # All encapsulated draw_rot arguments can be set with hash-options at creation time
      @image = options[:image]          if options[:image].is_a? Gosu::Image
      @image = Image[options[:image]]   if options[:image].is_a? String
      @x = options[:x] || 0
      @y = options[:y] || 0
      @angle = options[:angle] || 0
      @center_x = options[:center_x] || options[:center] || 0.5
      @center_y = options[:center_y] || options[:center] || 0.5
      @factor_x = options[:factor_x] || options[:factor] || 1.0
      @factor_y = options[:factor_y] || options[:factor] || 1.0
      @color = Gosu::Color.new(options[:color]) if options[:color].is_a? Bignum
      @color = options[:color]                  if options[:color].respond_to?(:alpha)
      @color = Gosu::Color.new(0xFFFFFFFF)      if @color.nil?
      @mode = options[:mode] || :default # :additive is also available.
      @zorder = options[:zorder] || 100
                        
      # gameloop/framework logic (TODO: use or get rid of)
      @update = options[:update] || true
      @draw = options[:draw] || true
    end
    
    # Quick way of setting both factor_x and factor_y
    def factor=(factor)
      @factor_x = @factor_y = factor
    end
          
    # Quick way of setting both center_x and center_y
    def center=(factor)
      @center_x = @center_y = factor
    end

    # Returns true if object is inside the game window, false if outside
    def inside_window?(x = @x, y = @y)
      x >= 0 && x <= $window.width && y >= 0 && y <= $window.height
    end

    # Returns true object is outside the game window 
    def outside_window?(x = @x, y = @y)
      not inside_window?(x,y)
    end
    
    def distance_to(object)
      distance(self.x, self.y, object.x, object.y)
    end
    
    def draw
      super
      @image.draw_rot(@x, @y, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode)
    end
  end  
end