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
  # ** This class is under heavy development, API will most likely change! **
  #
  # GameObjectMap can convert any set of game objects into a 2D-array for fast lookup
  # You can set any gridsize with :grid, defaults to [32,32]. The smaller the grid the more memory it will eat.
  #
  # Basic usage:
  #   @map = GameObjectMap.new(:game_objects => TerrainObject.all, :grid => [32, 32])
  #   @map.at(100, 100)         # returns one TerrainObject at x/y: 100/100
  #   @map.game_object(player)  # returns one TerrainObject which collides with player.bounding_box
  #
  # ** This class is under heavy development, API will most likely change! **
  #
  class GameObjectMap
    attr_reader :map, :game_object_positions
    
    def initialize(options = {})
      @game_objects = options[:game_objects]
      @grid = options[:grid] || [32,32]
      @debug = options[:debug]
      create_map
    end
    
    #
    # Creates a "tilemap" of game objects using @grid and @game_objects
    # Useful for faster collision detection on a grid-based freeform map created with the Edit game state.
    #
    def create_map
      @map = []
      @game_object_positions = {}
            
      @game_objects.each do |game_object|
        puts "#{game_object.class} @ #{game_object.x} / #{game_object.y}" if @debug
                
        start_x = (game_object.bb.left / @grid[0]).to_i
        stop_x =  ( (game_object.bb.right-1) / @grid[0] ).to_i
        
        #if game_object.zorder == 80
        #  puts "x: #{game_object.x}, y: #{game_object.y}"
        #  puts "width: #{game_object.width}, height: #{game_object.height}"
        #  puts "start_x: #{start_x}, stop_x: #{stop_x}"
        #end
        
        
        (start_x .. stop_x).each do |x|
          start_y = (game_object.bb.top / @grid[1] ).to_i
          stop_y =  ( (game_object.bb.bottom-1) / @grid[1] ).to_i
          
          @game_object_positions[game_object] = [(start_x .. stop_x), (start_y .. stop_y)]
          
          @map[x] ||= []
          (start_y .. stop_y).each do |y|
            @map[x][y] = game_object
          end
        end
      end
    end
    
    #
    # Removes a specific game object from the map
    #
    def clear_game_object(game_object)
      range_x, range_y = @game_object_positions[game_object]
      
      range_x.each do |x|
        range_y.each do |y|
          @map[x][y] = nil
        end
      end
    end
      
    #
    # Clear game object from the array-map on a certain X/Y
    #
    def clear_at(x, y)
      lookup_x = (x / @grid[0]).to_i
      lookup_y = (y / @grid[1]).to_i
      @map[lookup_x][lookup_y] = nil
    end

    #
    # Gets a game object from the array-map on a certain X/Y
    #
    def at(x, y)
      lookup_x = (x / @grid[0]).to_i
      lookup_y = (y / @grid[1]).to_i
      @map[lookup_x][lookup_y]  rescue nil
    end

    def from_game_object(game_object)
      start_x = (game_object.bb.left / @grid[0]).to_i
      stop_x =  (game_object.bb.right / @grid[0]).to_i
      
      (start_x .. stop_x).each do |x|
        start_y = (game_object.bb.top / @grid[1]).to_i
        stop_y =  (game_object.bb.bottom / @grid[1]).to_i
          
        (start_y .. stop_y).each do |y|
          return @map[x][y]   if @map[x] && @map[x][y]
        end
        
      end
      return nil
    end

  end
end
