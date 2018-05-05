module Gosu
  class Song
    DEFAULT_VOLUME = 1.0

    class << self
      attr_reader :resources
      protected :resources

      # Volume of Songs, not allowing for global volume settings.
      attr_reader :volume

      # Volume the song is played at, affected by Song.volume and Window#volume/muting.
      def effective_volume
        @volume * $window.effective_volume  # FIXME what if $window is nil?
      end

      # Volume of Songs, not allowing for global volume settings.
      def volume=(value)
        raise "Bad volume setting" unless value.is_a? Numeric

        old_volume = @volume
        @volume = [[value, 1.0].min, 0.0].max.to_f

        recalculate_volumes(old_volume, @volume)

        @volume
      end

      def init_sound
        @volume = DEFAULT_VOLUME
        nil
      end

      protected
      # Recalculate all song volumes, after a global volume (Window#volume or Song.volume) has updated.
      def recalculate_volumes(old_volume, new_volume)
        # Avoid divide-by-zero when working out how much to alter the value by.
        multiplier =  if old_volume == 0.0
                       (new_volume > 0) ? 1.0 : 0.0
                      else
                        new_volume / old_volume
                      end
        resources.each_value {|song| song.send(:effective_volume=, song.volume * effective_volume * multiplier) }
      end
    end

    init_sound

    alias_method :old_initialize, :initialize
    protected :old_initialize

    # Volume, as played.
    alias_method :effective_volume, :volume

    # Set the volume, as played.
    alias_method :effective_volume=, :volume=
    protected :effective_volume=

    # Accepts :volume (0.0..1.0) option, defaulting to 1.0.
    def initialize(filename, options = {})
      options = {
          volume: DEFAULT_VOLUME,
      }.merge! options

      old_initialize(filename)

      @muted = false
      self.volume = options[:volume]
    end

    # Volume, not affected by Song volume or the Window volume/muted.
    def volume
      @true_volume
    end

    def volume=(value)
      @true_volume = [[value, 0.0].max, 1.0].min

      self.effective_volume = @true_volume * self.class.effective_volume unless @muted

      volume
    end

    protected
    def mute
      self.effective_volume = 0.0
      self
    end

    protected
    def unmute
      self.effective_volume = @true_volume * self.class.effective_volume
      self
    end
  end
end
