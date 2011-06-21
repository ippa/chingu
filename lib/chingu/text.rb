#--
#
# Chingu -- OpenGL accelerated 2D game framework for Ruby
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
  #
  # Text is a class to give the use of Gosu::Font more rubyish feel and fit it better into Chingu.
  # Pure Gosu:
  #   @font = Gosu::Font.new($window, "verdana", 30)
  #   @font.draw("A Text", 200, 50, 55, 2.0)
  #
  # Chingu
  #   @text = Chingu::Text.new("A Text", :x => 200, :y => 50, :zorder => 55, :factor_x => 2.0)
  #   @text.draw  # usually not needed as Text is a GameObject and therefore autodrawn
  #
  # @text comes with a number of changable properties, x,y,zorder,angle,factor_x,color,mode etc.
  #
  class Text < Chingu::GameObject
    attr_accessor :text
    attr_reader :size, :gosu_font, :line_spacing, :align, :max_width, :background

    @@size = nil
    @@font = nil
    @@padding = 5
    def self.font; @@font; end
    def self.font=(value); @@font = value; end
    def self.size; @@size; end
    def self.size=(value); @@size = value; end
    def self.height; @@size; end
    def self.height=(value); @@size = value; end
    def self.padding; @@padding; end
    def self.padding=(value); @@padding = value; end
    
    #
    # Takes the standard GameObject-hash-arguments but also:
    #   :text               - a string of text
    #   :font_name|:font    - Name of a system font, or a filename to a TTF file (must contain ? does not work on Linux). 
    #   :height|:size       - Height of the font in pixels. 
    #   :line_spacing	      - Spacing between two lines of text in pixels. 
    #   :max_width	        - Width of the bitmap that will be returned. Text will be split into multiple lines to avoid drawing over the right border. When a single word is too long, it will be truncated.
    #   :align	            - One of :left, :right, :center or :justify. 
    #
    # if :max_width is given the text is drawn using :line_spacing, :align and :max_width
    #
    def initialize(text, options = {})      
      if text.is_a? Hash
        options = text
        text = nil
      end
     
      # We remove the :size param so it doesn't get to GameObject where it means something else
      @size = options.delete(:size) || options.delete(:height) || @@size || 15
      
      options = {:rotation_center => :top_left}.merge(options) 
      
      super(options)
        
      @text = text || options[:text] || "-No text specified-"
      @font =  options[:font] || @@font || Gosu::default_font_name()
      @line_spacing = options[:line_spacing] || 1
      @align = options[:align] || :left
      @max_width = options[:max_width]
      @padding = options[:padding] || @@padding

      @gosu_font = Gosu::Font[@font, @size]
      create_image  unless @image

      if options[:background]
        @background = GameObject.new(:image => options[:background])
        @background.attributes = self.attributes
        @background.color = ::Gosu::Color::WHITE
        @background.zorder -= 1
        @background.x -= @padding
        @background.y -= @padding
        @background.width = self.width + @padding * 2
        @background.height = self.height + @padding * 2
      end
      
      self.height = options[:height]  if options[:height]
    end
    
    #
    # Set a new text, a new image is created.
    #
    def text=(text)
      @text = text
      create_image
    end
    
    #
    # Returns the width, in pixels, the given text would occupy if drawn.
    #
    def width
      @gosu_font.text_width(@text, @factor_x)
    end
    
    #
    # Draws @background if present + our text in @image
    #
    def draw
      @background.draw  if @background    # draw our background, if any
      super                               # super -> GameObject#draw which draws out text in form of @image
    end
    
    private
    
    #
    # Create the actual image from text and parameters supplied.
    #
    def create_image
      if @max_width
        @image = Gosu::Image.from_text($window, @text, @font, @size, @line_spacing, @max_width, @align)
      else
        @image = Gosu::Image.from_text($window, @text, @font, @size)
      end
    end
  end
end
