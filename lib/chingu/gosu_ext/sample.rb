module Gosu
  class Sample
    DEFAULT_VOLUME = 1.0 # Default volume of new samples.

    class << self
      # Volume of all Samples.
      attr_reader :volume

      public
      # Volume of Samples, affected by Sample.volume and Window#volume and muting.
      def effective_volume
        @volume * $window.effective_volume
      end

      public
      # Set the global volume of Samples.
      def volume=(value)
        raise "Bad volume setting" unless value.is_a? Numeric

        @volume = [[value, 1.0].min, 0.0].max.to_f
      end

      public
      def init_sound
        @volume = DEFAULT_VOLUME
        nil
      end
    end

    init_sound

    # Volume of this Sample. This is multiplied by the volume in #play.
    attr_reader :volume

    alias_method :old_initialize, :initialize
    protected :old_initialize
    public
    # Accepts :volume (0.0..1.0) option, defaulting to 1.0.
    def initialize(filename, options = {})
      options = {
          volume: DEFAULT_VOLUME,
      }.merge! options

      @volume = options[:volume]

      old_initialize(filename)
    end

    public
    # Set the volume of this Sample. This is multiplied by the volume in #play.
    def volume=(value)
      raise "Bad volume setting" unless value.is_a? Numeric

      @volume = [[value, 1.0].min, 0.0].max.to_f
    end

    public
    # Volume the Sample will actually be played at, affected by Sample.volume and Window#volume.
    def effective_volume
      @volume * self.class.effective_volume
    end

    alias_method :old_play, :play
    protected :old_play
    public
    def play(volume = 1, speed = 1, looping = false)
      volume *= effective_volume
      old_play(volume, speed, looping) if volume > 0.0
    end
	
    alias_method :old_play_pan, :play_pan
    protected :old_play_pan
    public
    def play_pan(pan = 0, volume = 1, speed = 1, looping = false)
      volume *= effective_volume
      old_play_pan(pan, volume, speed, looping) if volume > 0.0
    end
  end
end