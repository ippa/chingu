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

  class Font
    # Font is a special case, since it has both a name and a size.
    include Chingu::NamedResource

    # Load a font with the given name and size.
    # @param [String] name Name of the font (or path to TTF font)
    # @param [Number] size Size of the font.
    def self.autoload(name, size)
      font_name = if path = find_file(name)
        path # Use the full path, found in the autoload dirs.
      else
        name # Font not found in the path. Assume it is an OS font.
      end

      return Gosu::Font.new($window, font_name, size)
    end

    # @overload self.[](name, size)
    #   Get a font with the given name and size.
    #   @param [String] name Name of the font (or path to TTF font)
    #   @param [Number] size Size of the font.
    #
    # @overload self.[](size)
    #   Get a font of a given size using the Gosu.default_font_name.
    #   @param [Number] size Size of the font.
    def self.[]( *args )
      case args.size
      when 1
        name = Gosu.default_font_name
        size = args[0]
      when 2
        name, size = args
      else
        raise ArgumentError, "wrong number of arguments (#{args.size} for 1 or 2)"
      end

      result = @resources[[name, size]]

      if result.nil?
        result = autoload(name, size)
        if result
          self[name, size] = result
          result.name = name
        end
      end

      return result
    end

    # Save a font with the given name and size.
    # @param [String] name Name of the font (or path to TTF font)
    # @param [Number] size Size of the font.
    # @param [Gosu::Font] font Font object to save.
    def self.[]=( name, size, font )
      @resources[[name, size]] = font
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
