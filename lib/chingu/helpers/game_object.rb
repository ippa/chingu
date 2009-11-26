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
      filename = options[:file] || "#{self.class.to_s.downcase}.yml"
      
      require 'yaml'
      
      if File.exists?(filename)
        game_objects = YAML.load_file(filename)
        game_objects.each do |game_object|
          game_object.each_pair do |klassname, attributes|
            begin
              klass = Kernel::const_get(klassname)
              unless klass.class == "GameObject"
                puts "Creating #{klassname.to_s}: #{attributes.to_s}"
                klass.create(attributes)
              end
            rescue
              puts "Couldn't create class '#{klassname}'"
            end
          end
        end
      end
    end
  
  end

  end
end