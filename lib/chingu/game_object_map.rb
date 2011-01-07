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
  # GameObjectMap can map any set of game objects into a 2D-array for fast lookup.
  # You can choose gridsize with the :grid-parameter, defaults to [32,32]. 
  # The smaller the grid the more memory GameObjectMap will eat.
  #
  # The game objects sent to GameObjectMap must respond to #bb (as provided by trait :bounding_box)
  # This is needed to calcuate what cells in the grid each game object covers.
  #
  # Basic usage:
  #   @map = GameObjectMap.new(:game_objects => TerrainObject.all, :grid => [32, 32])
  #   @map.at(100, 100)         # returns one TerrainObject at x/y: 100/100
  #   @map.game_object(player)  # returns one TerrainObject which collides with player.bounding_box
  #
  # A GameObjectMap is ment to be used for static non-moving objects, where a map can be calculated once and then used for fast lookups.
  # This makes GameObjectMap very well suited for terrain for a player to walk on / collide with.
  #
  # One cell in the GameObjectMap can only be occupied by one game object.
  # If you need many objects at the same cell, use 2 GameObjectMaps, something like:
  #
  #   @terrain = GameObjectMap.new(:game_objects => Terrain.all)
  #   @mines = GameObjectMap.new(:game_objects => Mine.all)
  #
  #   @player.stop_falling  if @terrain.at(@player.x, @player)
  #   @player.die           if @mine.at(@player.x, @player)
  #
  # Take note, since there can be only 1 game object per cell a huge game object could very well "cover out" another smaller game objects occupying the same cells.
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
        puts "#{game_object.class} @ #{game_object.x}/#{game_object.y} - #{game_object.bb}" if @debug
        insert(game_object)                
      end
    end
    
    #
    # Insert game_object into the map
    #
    def insert(game_object)
      start_x = ( game_object.bb.left / @grid[0] ).to_i
      stop_x =  ( game_object.bb.right / @grid[0] ).to_i
      
      (start_x ... stop_x).each do |x|
        start_y = ( game_object.bb.top / @grid[1] ).to_i
        stop_y =  ( game_object.bb.bottom / @grid[1] ).to_i
          
        @game_object_positions[game_object] = [(start_x ... stop_x), (start_y ... stop_y)]
          
        @map[x] ||= []
        (start_y ... stop_y).each do |y|
          @map[x][y] = game_object
          puts "#{game_object.class} => map[#{x}][#{y}]" if @debug
        end
      end      
    end
        
    #
    # Removes a specific game object from the map, replace the cell-value with nil
    #
    def delete(game_object)
      range_x, range_y = @game_object_positions[game_object]
      return unless range_x && range_y
      
      range_x.each do |x|
        range_y.each do |y|
          @map[x][y] = nil
        end
      end
    end
    alias :clear_game_object :delete
      
    #
    # Clear the game object residing in the cell given by real world coordinates x/y
    #
    def clear_at(x, y)
      lookup_x = (x / @grid[0]).to_i
      lookup_y = (y / @grid[1]).to_i
      @map[lookup_x][lookup_y] = nil
    end

    #
    # Gets game object from map that resides on real world coordinates x/y
    #
    def at(x, y)
      lookup_x = (x / @grid[0]).to_i
      lookup_y = (y / @grid[1]).to_i
      @map[lookup_x][lookup_y]  rescue nil  # Benchmark this against @map[lookup_x] && @map[lookup_x][lookup_y] => prob faster
    end

    #
    # Return the first game object occupying any of the cells that given 'game_object' covers
    #
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
    
    #
    # Yields all game objects occupying any of the cells that given 'game_object' covers
    #
    def each_collision(game_object)
      start_x = (game_object.bb.left / @grid[0]).to_i
      stop_x =  (game_object.bb.right / @grid[0]).to_i
      
      (start_x ... stop_x).each do |x|
        start_y = (game_object.bb.top / @grid[1]).to_i
        stop_y =  (game_object.bb.bottom / @grid[1]).to_i
          
        (start_y ... stop_y).each do |y|
          yield @map[x][y]   if @map[x] && @map[x][y] && @map[x][y] != game_object  # Don't yield collisions with itself
        end
      end
    end
    
  end
end
