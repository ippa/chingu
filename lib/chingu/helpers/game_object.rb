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
  # Convenience-methods for classes that hold game objects
  # Mixed into Chingu::Window and Chingu::GameState
  #
  module GameObject
  
    def add_game_object(object)
      @game_objects.add_game_object(object)
    end
    
    def remove_game_object(object)
      @game_objects.remove_game_object(object)
    end
    
    def game_objects
      @game_objects
    end
    
    def show_game_object(object)
      @game_objects.show_game_object(object)
    end    
    def hide_game_object(object)
      @game_objects.hide_game_object(object)
    end
    def pause_game_object(object)
      @game_objects.pause_game_object(object)
    end
    def unpause_game_object(object)
      @game_objects.unpause_game_object(object)
    end 
    
    
    #
    # Fetch game objects of a certain type/class
    #
    def game_objects_of_class(klass)
      @game_objects.select { |game_object| game_object.is_a? klass }
    end
    
    #
    # Creates game objects from a Chingu-spezed game objects file (created with game state 'Edit')
    #
    def load_game_objects(options = {})
      file = options[:file] || self.filename + ".yml"
      debug = options[:debug]
      except = Array(options[:except]) || []
      
      require 'yaml'
      
      puts "* Loading game objects from #{file}" if debug
      if File.exists?(file)
        objects = YAML.load_file(file)
        objects.each do |object|
          object.each_pair do |klassname, attributes|
            begin
              klass = Kernel::const_get(klassname)
              unless klass.class == "GameObject" && !except.include?(klass)
                puts "Creating #{klassname.to_s}: #{attributes.to_s}" if debug
                object = klass.create(attributes)
                object.options[:created_with_editor] = true if object.options
              end
            rescue
              puts "Couldn't create class '#{klassname}'"
            end
          end
        end
      end
    end
    
    #
    # Save given game_objects to a file. Hashoptions
    # 
    # :file - a String, name of file to write to, default is current game_state class name.
    # :game_objects - an Array, game objects to save
    # :classes      - an Array, save only game objects of theese classes
    #
    # NOTE: To save a color do:  :color => game_object.color.argb
    #
    def save_game_objects(options = {})
      #
      # TODO: Move this to GameObjectList#save ?
      #
      file = options[:file] || "#{self.class.to_s.downcase}.yml"
      game_objects = options[:game_objects]
      classes = options[:classes]
      attributes = options[:attributes] || [:x, :y, :angle, :zorder, :factor_x, :factor_y, :alpha]
      
      require 'yaml'
      objects = []
      game_objects.each do |game_object|
        # Only save specified classes, if given.
        next if classes and !classes.empty? and !classes.include?(game_object.class)
        
        attr_hash = {}
        attributes.each do |attr| 
          begin
          attr_hash[attr] = game_object.send(attr)
          rescue NoMethodError
            # silently ignore attributes that doesn't exist on the particular game object
          end
        end
        objects << {game_object.class.to_s => attr_hash}
      end

      File.open(file, 'w') { |out| YAML.dump(objects, out) }
    end
    
  end

  end
end