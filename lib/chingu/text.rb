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
    attr_reader :height, :gosu_font, :line_spacing, :align, :max_width

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
    #   :text               - a string of text
    #   :font_name|:font    - Name of a system font, or a filename to a TTF file (must contain ’/’, does not work on Linux). 
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
     
      super(options)
  
      @text = text || options[:text] || "-No text specified-"
      @font =  options[:font] || @@font || default_font_name()
      @height = @size = options[:height] || options[:size] || @@size || 15
      @line_spacing = options[:line_spacing] || 1
      @align = options[:align] || :left
      @max_width = options[:max_width]
    
      self.rotation_center(:top_left)
      
      @gosu_font = Gosu::Font.new($window, @font, @height)
      
      create_image  unless @image
    end
    
    #
    # Set a new text, a new image is created.
    #
    def text=(text)
      @text = text
      create_image
    end
    
    def size
      @height
    end
    
    #
    # Returns the width, in pixels, the given text would occupy if drawn.
    #
    def width
      @gosu_font.text_width(@text, @factor_x)
    end
    
    private
    
    #
    # Create the actual image from text and parameters supplied.
    #
    def create_image
      if @max_width
        @image = Gosu::Image.from_text($window, @text, @font, @height, @line_spacing, @max_width, @align)
      else
        @image = Gosu::Image.from_text($window, @text, @font, @height)
      end
    end
  end
end
