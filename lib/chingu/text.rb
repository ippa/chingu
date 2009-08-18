module Chingu
  #
  # Text is a class to give the use of Gosu::Font more rubyish feel and fit it better into Chingu.
  # Pure Gosu:
  #   @font = Gosu::Font.new($window, "verdana", 30)
  #   @font.draw("A Text", 200, 50, 55, 2.0)
  #
  # Chingu
  #   @text = Chingu::Text.new(:text => "A Text", :x => 200, :y => 50, :zorder => 55, :factor_x => 2.0)
  #   @text.draw  # usually not needed as Text is a GameObject and therefore autodrawn
  #
  # @text comes with a number of changable properties, x,y,zorder,angle,factor_x,color,mode etc.
  #
  class Text < Chingu::GameObject
    attr_accessor :text
    attr_reader :height, :gosu_font

    @@size = nil
    @@font = nil
    def self.font; @@font; end
    def self.font=(value); @@font = value; end

    def self.size; @@size; end
    def self.size=(value); @@size = value; end
    def self.height; @@size; end
    def self.height=(value); @@size = value; end
    
    #
    # Takes the standard GameObject-hash-arguments but also:
    # - :text             - a string of text
    # - :font_name|:font  - name of a systemfont (default: "verdana")
    # - :height|size      - how many pixels high should the text be
    #
    def initialize(options)
      super(options)
      @text = options[:text] || "-No text specified-"
      @font =  options[:font] || @@font || default_font_name()
      @height = options[:height] || options[:size] || @@size || 15
      
      @gosu_font = Gosu::Font.new($window, @font, @height)
    end
    
    def draw
      @gosu_font.draw_rot(@text, @x.to_i, @y.to_i, @zorder, @angle, @factor_x, @factor_y, @color, @mode)
    end
    
    #
    # Returns the width, in pixels, the given text would occupy if drawn.
    #
    def width
      @gosu_font.text_width(@text, @factor_x)
    end

  end
  
end
