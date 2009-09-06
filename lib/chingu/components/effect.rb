module Chingu
  module Components
    class Effect
      #
      # Adds .rotating .fading and .zooming to any GameObject.
      #
      # TODO: better naming? suggestions:
      #
      # basic gosu unit <-> automation name
      # ==============================================
      # angle <-> rotation? rotating? automatic_angle?
      # factor <-> growth? scale? automatic_zoom?
      # alpha <-> fade
      #
      def initialize(parent_class, options)
        @parent_class = parent_class        
        @parent_class.class_eval do
          attr_accessor :rotating, :fading, :zooming
          
          # Zoom - increase @factor_x and @factor_y at the same time.
          def zoom(amount = 0.1)
            @factor_x += amount
            @factor_y += amount
          end
          
          # Zoom Out - decrease @factor_x and @factor_y at the same time.
          def zoom_out(amount = 0.1)
            @factor_x -= amount
            @factor_y -= amount
          end
    
          # Rotate object 'amount' degrees
          def rotate(amount = 1)
            @angle += amount
          end
  
          # Fade object by decreasing/increasing color.alpha
          def fade(amount = 1)
            return if amount == 0
            
            new_alpha = @color.alpha + amount
            if amount < 0
              @color.alpha =  [0, new_alpha].max
            else
              @color.alpha =  [0, new_alpha].min
            end
          end

          # Fade out objects color by decreasing color.alpha
          def fade_out(amount = 1)
            fade(-amount)
          end

          # Fade in objects color by increasing color.alpha
          def fade_in(amount = 1)
            fade(amount)
          end
        end
      end
      
      #
      # Setup
      #
      def setup(parent_instance, options)
        @parent_instance = parent_instance
        @parent_instance.instance_eval do
          @rotating = options[:rotating] || nil
          @zooming = options[:zooming] || nil
          @fading = options[:fading] || nil
        end
      end
      
      def update(parent)
        parent.rotate(parent.rotating)    if parent.rotating
        parent.fade(parent.fading)        if parent.fading
        parent.zoom(parent.zooming)       if parent.zooming
      end
    end
  end
end