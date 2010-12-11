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
  # Manages a list of game objects
  # An instance of GameObjectList is automaticly created as "game_objects" if using Chingu::Window
  #
  class GameObjectList
        
    def initialize(options = {})
      @game_objects = options[:game_objects] || []
      @add_game_objects = []
      @remove_game_objects = []      
    end
    
    def to_s
      "#{@game_objects.size} game objects."
    end
    
    def of_class(klass)
      @game_objects.select { |game_object| game_object.is_a? klass }
    end
    
    def destroy_all
      @game_objects.clear
    end
    alias :clear :destroy_all
    alias :remove_all :destroy_all
    
    def add_game_object(object)
      @game_objects.push(object)
      #@add_game_objects.push(object)
    end
    
    def remove_game_object(object)
      @game_objects.delete(object)
      #@remove_game_objects.push(object)
    end
        
    def destroy_if
      @game_objects.reject! { |object| yield(object) }
    end
    
    def size
      @game_objects.size
    end
    
    def empty?
      @game_objects.empty?
    end
    
    def draw
      @game_objects.select { |object| object.visible }.each do |object|
        object.draw_trait
        object.draw
      end
    end

    def draw_relative(x=0, y=0, zorder=0, angle=0, center_x=0, center_y=0, factor_x=0, factor_y=0)
      @game_objects.select { |object| object.visible }.each do |object| 
        object.draw_trait
        object.draw_relative(x, y, zorder, angle, center_x, center_y, factor_x, factor_y)
      end
    end
          
    def update
      @game_objects.select { |object| not object.paused }.each do |object| 
        object.update_trait 
        object.update
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
    
    def first
      @game_objects.first
    end

    def last
      @game_objects.last
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
    
    private
    
    def sync
      @game_objects += @add_game_objects
      @add_game_objects.clear
      
      @game_objects -= @remove_game_objects
      @remove_game_objects.clear      
    end    
  end  
end
