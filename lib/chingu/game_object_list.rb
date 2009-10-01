#--
#
# Chingu -- Game framework built on top of the opengl accelerated gamelib Gosu
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
        
    def initialize
      @game_objects = Array.new
      #@game_objects_by_class = Hash.new
    end
    
    def to_s
      "#{@game_objects.size} game objects."
    end
    
    def of_class(klass)
      @game_objects.select { |game_object| game_object.is_a? klass }
      #@game_objects_by_class[klass] || []
    end
    
    def remove_all
      @game_objects.clear
      #@game_objects_of_class.clear
    end
    alias :clear :remove_all
    
    def add_game_object(object)
      @game_objects.push(object)
      #(@game_objects_by_class[object.class] ||= []).push(object)
    end
    
    def remove_game_object(object)
      @game_objects.delete(object)
      #@game_objects_by_class[object.class].delete(object)
    end
    
    def destroy_if
      @game_objects.reject! { |object| yield(object) }
      #@game_objects_by_class.delete_if { |klass, object| yield(object) }
    end
    
    def size
      @game_objects.size
    end
    
    def draw
      @game_objects.each{ |object| object.visible }.each do |object| 
        object.draw_trait
        object.draw
      end
    end
    
    def update
      @game_objects.select{ |object| not object.paused }.each do |object| 
        object.update_trait 
        object.update
      end
    end
    
    def each
      @game_objects.each { |object| yield object }
    end
    
    def select
      @game_objects.select { |object| yield object }
    end
  end  
end