#
# Rubygames Named Resources for GOSU
# Assumes a global variable $window having the Gosu::Window instance.
# Quick 'n easy access to sprites, sounds and tiles!
#
module Chingu
  def media_path(file)
    File.join($window.root, "media", file)  
  end
  
  def image_path(file)
    File.join($window.root, "gfx", file)
  end
  
  class ImagePath
    include Chingu::NamedResource
		
    def self.autoload(name)
    find_file(name)
    end
  end
end

module Gosu
  class Image
    include Chingu::NamedResource
    
    def self.autoload(name)
      (path = find_file(name)) ? Gosu::Image.new($window, path, true) : nil
    end
  end

  class Song
    include Chingu::NamedResource
		
    def self.autoload(name)
      (path = find_file(name)) ? Gosu::Song.new($window, path) : nil
    end
  end
  
  class Sample
    include Chingu::NamedResource
    
    def self.autoload(name)
      (path = find_file(name)) ? Gosu::Sample.new($window, path) : nil
    end
  end
  Sound = Sample
	
  class Tile
    include Chingu::NamedResource	
	
    def self.autoload(name)
      (path = find_file(name)) ? Gosu::Image.load_tiles($window, path, 32, 32, true) : nil
    end
  end
  
  class CutTiles
    def self.[](name, width, height)
      @@tiles = Hash.new unless defined?(@@tiles)
      @@tiles[name] ||= Gosu::Image.load_tiles($window, name, width, height, true)
    end
  end
end