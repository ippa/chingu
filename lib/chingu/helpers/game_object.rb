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
      # puts "#{self.to_s} add_game_object(#{object.to_s})"
      @game_objects.add_game_object(object)
    end
    
    def remove_game_object(object)
      @game_objects.remove_game_object(object)
    end
    
    def game_objects
      @game_objects
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
      self.game_objects.sync
    end
    
    #
    # Save given game_objects to a file. Hashoptions
    # 
    # :file - a String, name of file to write to, default is current game_state class name.
    # :game_objects - an Array, game objects to save
    # :classes      - an Array, save only game objects of theese classes
    #
    def save_game_objects(options = {})
      file = options[:file] || "#{self.class.to_s.downcase}.yml"
      game_objects = options[:game_objects]
      classes = options[:classes]
      
      require 'yaml'
      objects = []
      game_objects.each do |game_object|
        # Only save specified classes, if given.
        next if classes and !classes.empty? and !classes.include?(game_object.class)
        
        objects << {game_object.class.to_s  => 
                      {
                      :x => game_object.x, 
                      :y => game_object.y,
                      :angle => game_object.angle,
                      :zorder => game_object.zorder,
                      :factor_x => game_object.factor_x,
                      :factor_y => game_object.factor_y,
                      :color => game_object.color.argb,
                      #:color => sprintf("0x%x",game_object.color.argb)
                      #:center_x => game_object.center_x,
                      #:center_y => game_object.center_y,
                      }
                    }
      end

        
      #Marshal.dump(previous_game_state.game_objects, File.open(@filename, "w"))
      File.open(file, 'w') do |out|
        YAML.dump(objects, out)
      end
    end
    
  
  end

  end
end