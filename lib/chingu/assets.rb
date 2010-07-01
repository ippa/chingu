#
# Rubygames Named Resources for GOSU
# Assumes a global variable $window having the Gosu::Window instance.
# Quick 'n easy access to sprites, sounds and tiles!
#
module Chingu
  def media_path(file)
    File.join(ROOT, "media", file)  
  end

  def root_path(file)
    File.join(ROOT, file)  
  end

  def image_path(file)
    File.join(ROOT, "images", file)
  end
  
  class Asset
    include Chingu::NamedResource
		
    def self.autoload(name)
      find_file(name)
    end
  end
end

#
# Extend GOSU's core classes with NamedResource
#
module Gosu
  class Image
    include Chingu::NamedResource
    
    def self.autoload(name)
      ret = (path = find_file(name)) ? Gosu::Image.new($window, path, false) : nil
      raise "Can't load image \"#{name}\"" if ret.nil?
      return ret
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
  Sound = Sample  # Gosu uses Sample, but Sound makes sense too.
end
