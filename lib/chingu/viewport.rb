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
  # A basic Viewport class
  #
  # TODO:
  # Implement use of viewports angle, center_x, center_y, factor_x, factor_y
  #
  class Viewport
    attr_accessor :x, :y, :x_min, :x_max, :y_min, :y_max
    #attr_accessor :angle, :center_x, :center_y, :factor_x, :factor_y
    
    def initialize(options = {})
      @x = options[:x] || 0
      @y = options[:y] || 0
      @angle = options[:angle] || 0
      
      #self.factor = options[:factor] || options[:scale] || 1.0
      #@factor_x = options[:factor_x] if options[:factor_x]
      #@factor_y = options[:factor_y] if options[:factor_y]
      
      #self.center = options[:center] || 0.5
      #@rotation_center = options[:rotation_center]
      #self.rotation_center(options[:rotation_center]) if options[:rotation_center]
      
      #@center_x = options[:center_x] if options[:center_x]
      #@center_y = options[:center_y] if options[:center_y]
      
      @x_min = nil
      @x_max = nil
      @y_min = nil
      @y_max = nil      
    end
    
    def x=(x)
      @x = x
      @x = @x_min   if @x_min && @x < @x_min
      @x = @x_max   if @x_max && @x > @x_max
    end

    def y=(y)
      @y = y
      @y = @y_min   if @y_min && @y < @y_min
      @y = @y_max   if @y_max && @y > @y_max
    end
    
  end
end