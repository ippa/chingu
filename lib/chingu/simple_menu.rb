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
  # 
  #
  class SimpleMenu < BasicGameObject
    include Chingu::Helpers::InputClient
    include Chingu::Helpers::InputDispatcher
    
    attr_accessor :menu_items
    
    def initialize(options = {})
      super
      
      @menu_items = options.delete(:menu_items)# || {"Exit" => :exit}
      
      @x = options.delete(:x) || $window.width/2
      @y = options.delete(:x) || 100
      @spacing = options.delete(:x) || 100
      @items = []
  
      y = @spacing
      menu_items.each do |key, value|
        
        item = if key.is_a? String
          Text.new(key, options.dup)
        elsif key.is_a? Image
          GameObject.new(:image => key)
        elsif key.is_a? GameObject
          menu_item.options.merge!(options.dup)
          menu_item
        end
        
        item.options[:on_select] = method(:on_select)
        item.options[:on_deselect] = method(:on_deselect)
        item.options[:action] = value
        
        item.rotation_center = :center_center
        item.x = @x
        item.y = y
        y += item.height + @spacing
        @items << item
      end      
      @selected = options[:selected] || 0
      step(0)
      
      self.input = {:up => lambda{step(-1)}, :down => lambda{step(1)}, [:return, :space, :right] => :select}
    end
    
    def step(value)
      selected.options[:on_deselect].call(selected)
      @selected += value
      @selected = @items.count-1  if @selected < 0
      @selected = 0               if @selected == @items.count
      selected.options[:on_select].call(selected)
    end
    
    def select
      dispatch_action(selected.options[:action], self.parent)
    end
            
    def selected
      @items[@selected]
    end
      
    def on_deselect(object)
      object.color = Color::WHITE
    end
    
    def on_select(object)
      object.color = Color::RED
    end
    
    def draw
      @items.each { |item| item.draw }
    end
    
  end
end
 