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

require 'forwardable'

module Chingu
  #
  # Manages a list of game objects
  # An instance of GameObjectList is automaticly created as "game_objects" if using Chingu::Window
  #
  class GameObjectList
    extend Forwardable
    
    attr_reader :visible_game_objects, :unpaused_game_objects
        
    def initialize(options = {})
      @game_objects = options[:game_objects] || []
      @visible_game_objects = []
      @unpaused_game_objects = []
    end
    
    def_delegator :@game_objects, :size
    def_delegator :@game_objects, :empty?
    def_delegator :@game_objects, :first
    def_delegator :@game_objects, :last
    
    def to_s
      "#{@game_objects.size} game objects."
    end
    
    def of_class(klass)
      @game_objects.select { |game_object| game_object.is_a? klass }
    end
    
    def destroy_all
      @game_objects.each { |game_object| game_object.destroy }
    end
    alias :clear :destroy_all
    alias :remove_all :destroy_all
    
    def show_game_object(object)
      @visible_game_objects.push(object)
    end    
    def hide_game_object(object)
      @visible_game_objects.delete(object)
    end
    def pause_game_object(object)
      @unpaused_game_objects.delete(object)
    end
    def unpause_game_object(object)
      @unpaused_game_objects.push(object)
    end
    
    def add_game_object(object)
      @game_objects.push(object)
      @visible_game_objects.push(object)  if object.respond_to?(:visible)  && object.visible
      @unpaused_game_objects.push(object) if object.respond_to?(:paused)   && !object.paused
    end
    
    def remove_game_object(object)
      @game_objects.delete(object)
      @visible_game_objects.delete(object)
      @unpaused_game_objects.delete(object)
    end
    
    def destroy_if
      @game_objects.select { |object| object.destroy if yield(object) }
    end
    
    def update
      @unpaused_game_objects.each { |go| go.update_trait; go.update; }
    end
    def force_update
      @game_objects.each { |go| go.update_trait; go.update; }
    end
    
    def draw
      @visible_game_objects.each { |go| go.draw_trait; go.draw; }
    end
    def force_draw
      @game_objects.each { |go| go.draw_trait; go.draw }
    end

    def draw_relative(x=0, y=0, zorder=0, angle=0, center_x=0, center_y=0, factor_x=0, factor_y=0)
      @visible_game_objects.each do |object| 
        object.draw_trait
        object.draw_relative(x, y, zorder, angle, center_x, center_y, factor_x, factor_y)
      end
    end
          
    
    def each
      @game_objects.dup.each { |object| yield object }
    end
    
    def each_with_index
      @game_objects.dup.each_with_index { |object, index| yield object, index }
    end
    
    def select
      @game_objects.dup.select { |object| yield object }
    end

    def map
      @game_objects.map { |object| yield object }
    end

    #
    # Disable automatic calling of update() and update_trait() each game loop for all game objects
    #
    def pause!
      @game_objects.each { |object| object.pause! }
    end
    alias :pause :pause!
    
    #
    # Enable automatic calling of update() and update_trait() each game loop for all game objects
    #
    def unpause!
      @game_objects.each { |object| object.unpause! }
    end
    alias :unpause :unpause!
    
    #
    # Disable automatic calling of draw and draw_trait each game loop for all game objects
    #
    def hide!
      @game_objects.each { |object| object.hide! }
    end
    alias :hide :hide!
    
    #
    # Enable automatic calling of draw and draw_trait each game loop for all game objects
    #
    def show!
      @game_objects.each { |object| object.show! }
    end
    alias :show :show!
    
  end  
end
