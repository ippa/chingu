module Chingu
  #
  # GameObject is our BasisGameObject (class with framespecific stuff)
  #
  # On top of that, it encapsulates GOSUs Image#draw_rot and all its parameters.
  #

  class GameObject < Chingu::BasicGameObject
    attr_accessor :image, :x, :y, :angle, :center_x, :center_y, :factor_x, :factor_y, :color, :mode, :zorder
    
    #
    # returns [center_x, center_y]
    #
    @@rotation_centers = {
      :top_left => [0,0],
      :left_top => [0,0],
      
      :center_left => [0,0.5],
      :left_center => [0,0.5],
      
      :bottom_left => [0,1],
      :left_bottom => [0,1],
      
      :top_center => [0.5,0],
      :center_top => [0.5,0],
      
      :center_center => [0.5,0.5],
      :center => [0.5,0.5],
      
      :bottom_center => [0.5,1],
      :center_bottom => [0.5,1],
      
      :top_right => [1,0],
      :right_top => [1,0],
      
      :center_right => [1,0.5],
      :right_center => [1,0.5],
      
      :bottom_right => [1,1],
      :right_bottom => [1,1]
    }
    
    #
    # Sets @center_x and @center_y according to given alignment. Available alignments are:
    #
    #   :top_left, :center_left, :bottom_left, :top_center, 
    #   :center_center, :bottom_center, :top_right, :center_right and :bottom_right
    #
    # They're also available in the opposite order with the same meaning.
    #
    def rotation_center(alignment)
      @center_x, @center_y = @@rotation_centers[alignment.to_sym]
    end
    
    def initialize(options = {})
      super

      # All encapsulated draw_rot arguments can be set with hash-options at creation time
      if options[:image].is_a?(Gosu::Image)
        @image = options[:image]
      elsif options[:image].is_a? String
        @image = Image[options[:image]]
      end
      
      @x = options[:x] || 0
      @y = options[:y] || 0
      @angle = options[:angle] || 0
      
      @center_x = options[:center_x] || options[:center] || 0.5
      @center_y = options[:center_y] || options[:center] || 0.5
      @factor_x = options[:factor_x] || options[:factor] || 1.0
      @factor_y = options[:factor_y] || options[:factor] || 1.0

      # faster?
      #self.center = options[:center] || 0.5
      #self.factor = options[:factor] || 1.0
      #@center_x = options[:center_x] || 0.5
      #@center_y = options[:center_y] || 0.5
      #@factor_x = options[:factor_x] || 1.0
      #@factor_y = options[:factor_y] || 1.0

      if options[:color].is_a?(Gosu::Color)
        @color = options[:color]
      elsif options[:color].is_a? Bignum
        @color = Gosu::Color.new(options[:color])
      else
        @color = Gosu::Color.new(0xFFFFFFFF)
      end
      
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