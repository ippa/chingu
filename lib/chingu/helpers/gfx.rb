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
  module Helpers
    
  #
  # Various helper-methods to manipulate the screen.
  # All drawings depend on the global variable $window which should be an instance of Gosu::Window or Chingu::Window
  #
  module GFX
    
    CIRCLE_STEP = 10
    
    #
    # Fills whole window with specified 'color' and 'zorder'
    #
    #def fill(color, zorder = 0)
    #  $window.draw_quad(0, 0, color,
    #                    $window.width, 0, color,
    #                    $window.width, $window.height, color,
    #                    0, $window.height, color,
    #                    zorder, :default)
    #end
    #
    
    # Fills window or a given rect with a gradient between two colors.
    #
    #   :from         - Start with this color
    #   :to           - End with this color
    #   :rect         - Only fill rectangle :rect with the gradient, either a Rect-instance or [x,y,width,height] Array.
    #   :orientation  - Either :vertical (top to bottom) or :horizontal (left to right)
    #
    
    def fill(material, zorder = 0, mode = :default)
      #
      # if only 1 color-argument is given, assume fullscreen simple color fill.
      #
      if material.is_a?(Gosu::Color)
        rect = Rect.new([0, 0, $window.width, $window.height])
        _fill_rect(rect, material, material, material, material, zorder, mode)
      else
        fill_gradient(material)
      end
    end
    
    #
    # Draws an unfilled rect in given color
    #
    def draw_rect(rect, color, zorder = 0, mode = :default)
      rect = Rect.new(rect) unless rect.is_a? Rect
      _stroke_rect(rect, color, color, color, color, zorder, mode)
    end
    
    
    #
    # Fills a given Rect 'rect' with Color 'color', drawing with zorder 'zorder'
    #
    def fill_rect(rect, color, zorder = 0, mode = :default)
      rect = Rect.new(rect) unless rect.is_a? Rect
      _fill_rect(rect, color, color, color, color, zorder, mode)
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
      options = { :from => Gosu::Color::BLACK,
                  :to => Gosu::Color::WHITE,
                  :orientation => :vertical,
                  :rect => [0, 0, $window.width, $window.height],
                  :zorder => 0,
                  :mode => :default
                }.merge!(options)
      
      rect   = Rect.new(options[:rect])
      colors = options[:colors] || options.values_at(:from, :to)
      zorder = options[:zorder]
      mode   = options[:mode]
      
      case options[:orientation]
      when :vertical
        rect.height /= colors.count - 1
        colors.each_cons(2) do |from, to|
          _fill_rect(rect, from, to, to, from, zorder, mode)
          rect.top += rect.height
        end
      when :horizontal
        rect.width /= colors.count - 1
        colors.each_cons(2) do |from, to|
          _fill_rect(rect, from, from, to, to, zorder, mode)
          rect.left += rect.width
        end
      else
        raise ArgumentError, "bad gradient orientation: #{options[:orientation]}"
      end
      
    end
    
    #
    # Draws an unfilled circle, thanks shawn24!
    #
    def draw_circle(cx, cy, r, color, zorder = 0, mode = :default)
      draw_arc(cx, cy, r, 0, 360, color, zorder, mode)
    end
    
    #
    # Draws an unfilled arc from a1 to a2
    #
    def draw_arc(cx, cy, r, from, to, color, zorder = 0, mode = :default)
      from, to = to, from if from > to
      from.step(to, CIRCLE_STEP).each_cons(2) do |a1, a2|
        _draw_arc_strip(cx, cy, r, a1, a2, color, zorder, mode)
      end
    end
    
    #
    # Draws a filled circle
    #
    def fill_circle(cx, cy, r, color, zorder = 0, mode = :default)
      fill_arc(cx, cy, r, 0, 360, color, zorder, mode)
    end
    
    #
    # Draws a filled arc from a1 to a2
    #
    def fill_arc(cx, cy, r, from, to, color, zorder = 0, mode = :default)
      from, to = to, from if from > to
      from.step(to, CIRCLE_STEP).each_cons(2) do |a1, a2|
        _fill_arc_strip(cx, cy, r, a1, a2, color, zorder, mode)
      end
    end
    
    private
    
    def _fill_rect(rect, color_a, color_b, color_c, color_d, zorder, mode)
      left,  top    = *rect.topleft
      right, bottom = *rect.bottomright
      $window.draw_quad(left,  top,    color_a,
                        left,  bottom, color_b,
                        right, bottom, color_c,
                        right, top,    color_d,
                        zorder, mode)
    end
    
    def _stroke_rect(rect, color_a, color_b, color_c, color_d, zorder, mode)
      left,  top    = *rect.topleft
      right, bottom = *rect.bottomright
      $window.draw_line(left,  top,    color_a, left,  bottom, color_b, zorder, mode)
      $window.draw_line(left,  bottom, color_b, right, bottom, color_c, zorder, mode)
      $window.draw_line(right, bottom, color_c, right, top,    color_d, zorder, mode)
      $window.draw_line(right, top,    color_d, left,  top,    color_a, zorder, mode)
    end
    
    def _draw_arc_strip(cx, cy, r, a1, a2, color, zorder = 0, mode = :default)
      $window.translate(cx, cy) do
        x1, y1 = Gosu.offset_x(a1, r), Gosu.offset_y(a1, r)
        x2, y2 = Gosu.offset_x(a2, r), Gosu.offset_y(a2, r)
        $window.draw_line(x1, y1, color,
                          x2, y2, color,
                          zorder, mode)
      end
    end
    
    def _fill_arc_strip(cx, cy, r, a1, a2, color, zorder = 0, mode = :default)
      $window.translate(cx, cy) do
        x1, y1 = Gosu.offset_x(a1, r), Gosu.offset_y(a1, r)
        x2, y2 = Gosu.offset_x(a2, r), Gosu.offset_y(a2, r)
        $window.draw_triangle(0,  0,  color,
                              x1, y1, color,
                              x2, y2, color,
                              zorder, mode)
      end
    end
    
  end
  
  end
end