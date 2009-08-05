#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2008  John Croisant
#
#	This library is free software; you can redistribute it and/or
#	modify it under the terms of the GNU Lesser General Public
#	License as published by the Free Software Foundation; either
#	version 2.1 of the License, or (at your option) any later version.
#
#	This library is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#	Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public
#	License along with this library; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++


module Chingu

  #  NamedResource is a mix-in module to implement a globally-available
  #  resource table, a @name variable and accessors, and a system for
  #  automatically loading resources when they are first needed.
  #
  #  This module is used for Rubygame::Music, Rubygame::Sound, and
  #  Rubygame::Surface. You can use it in your own classes this way:
  #
  #  1. Do 'include Rubygame::NamedResource' in your class definition.
  #
  #  2. Set MyClass.autoload_dirs to an Array of directories to look
  #     for files when autoloading. Tip: use File.join to create
  #     paths that work on any operating system.
  #
  #  3. Define #autoload to implement the behavior for your class,
  #     or leave it as the default if you don't need autoloading.
  #     See the docs for #autoload for more information.
  #
  #  Here's an example of how you could use this for a class which
  #  loads maps from a file:
  #
  #      class Map
  #        include Rubygame::NamedResource
  #
  #        Map.autoload_dirs = [ File.join("maps","world_1"),
  #                              File.join("maps","custom") ]
  #
  #        def autoload( name )
  #          # Searches autoload_dirs for the file
  #          path = find_file( name )
  #
  #          if( path )
  #            return load_map( path )
  #          else
  #            return nil
  #          end
  #        end
  #
  #        def load_map( path )
  #          # Your code to do the real loading, then return
  #          # the created instance of Map class.
  #          # ...
  #          return map_instance
  #        end
  #      end
  #
  #  Here's an example of how you could then use the Map class:
  #
  #      map = Map["level_1.map"]
  #
  #      if( map )
  #        start_playing( map )
  #      else
  #        raise "Oops! The map file for Level 1 doesn't exist!"
  #      end
  #
  module NamedResource


    #  Adds class methods when the NamedResource module is included
    #  in a class. (Here, we are assuming that the NamedResource
    #  module was included in a class called MyClass.)
    module NamedResourceClassMethods

      #  An Array of paths to check for files. See #find_file.
      attr_accessor :autoload_dirs


      #  call-seq:
      #    MyClass[ name ]  ->  instance or nil
      #
      #  Retrieves an instance of the class from a per-class resource
      #  table (Hash).
      #
      #  If no object has been saved under the given name, invoke
      #  #autoload to try to load a new instance, store it in the
      #  Hash table under this name, and sets the instance's @name
      #  to this name.
      #
      def []( name )
        result = @resources[name]

        if result.nil?
          result = autoload(name)
          if result
            self[name] = result
            result.name = name
          end
        end

        return result
      end


      #  call-seq:
      #    MyClass[ name ] = instance
      #
      #  Stores an instance of the class in a per-class resource table
      #  (Hash) for future access. If another object is already stored
      #  with this name, the old record is lost.
      #
      #  May raise:  TypeError, if you try to store anything
      #             that is not kind of this class.
      #
      def []=( name, value )
        ##if( value.kind_of? self )
          @resources[name] = value
        ##else
        ## raise TypeError, "#{self}#[]= can only store instances of #{self}"
        ##end
      end

      #  call-seq:
      #    MyClass.autoload( name )  ->  instance or nil
      #
      #  This method is invoked when a non-existing resource is
      #  accessed with #[]. By default, this method simply returns
      #  nil, effectively disabling autoloading.
      #
      #  You should override this method in your class to provide
      #  class-specific loading behavior, or leave it as the default if
      #  you don't need autoloading. Your method should return either
      #  an instance of the class, or nil.
      #
      #  NOTE: The #find_file method is useful for getting the full
      #  path to a file which matches the name. That's what it's there
      #  for, so you should use it!
      #
      def autoload( name )
        nil
      end


      #  call-seq:
      #    MyClass.basename( path )  ->  filename
      #
      #  Returns the basename for the path (i.e. the
      #  filename without the directory). Same as
      #  File.basename
      #
      def basename( path )
        File.basename( path )
      end


      #  call-seq:
      #    MyClass.exist?( path )  ->  true or false
      #
      #  True if the given path points to a file
      #  that exists, otherwise false. Same as
      #  File.exist?
      #
      def exist?( path )
        File.exist?(path)
      end


      #  call-seq:
      #    MyClass.find_file( filename )  ->  path or nil
      #
      #  Checks every directory in @autoload_dirs for
      #  a file with the given name, and returns the
      #  path (directory and name) for the first match.
      #
      #  If no directories have a file with that name,
      #  return nil.
      #
      def find_file( filename )
        dir = @autoload_dirs.find { |dir|
          exist?( File.join(dir,filename) )
        }

        if dir
          return File.join(dir,filename)
        else
          return nil
        end
      end

    end


    #  Sets up the class when this module is included.
    #  Adds the class methods and defines class instance
    #  variables.
    def self.included( object ) # :nodoc:

      class << object
        include NamedResourceClassMethods
      end

      object.instance_eval do
        @resources = Hash.new
        @autoload_dirs = []
      end

    end


    # Returns the instance's @name. See also #name=.
    def name
      @name
    end

    #
    #  Sets the instance's @name to the given String, or nil to
    #  unset the name. See also #name.
    #
    #  NOTE: This does not automatically store the instance in the
    #  class resource table by name. Use the #[]= class method to do
    #  that.
    #
    #  The string is dup'ed and frozen before being stored.
    #
    #  May raise:  TypeError, if new_name is not a String or nil.
    #
    def name=( new_name )
      if new_name.nil?
        return @name = nil
      end

      unless new_name.kind_of? String
        raise TypeError, "name must be a String (got #{new_name.class})"
      end

      @name = new_name.dup
      @name.freeze
    end


  end

end
