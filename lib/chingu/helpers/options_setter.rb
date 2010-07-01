module Chingu
  module Helpers

    #
    # Provides #set_options and simple #initialize method to
    # simplify initialization from Hash.
    #
    module OptionsSetter

      #
      # Passes supplied options and DEFAULTS (if defined)
      # to #set_options method.
      #
      def initialize(options = {})
        set_options(options, self.class::DEFAULTS || {})
      end
      
      protected
      
      #
      # Takes hash and sets the instance variables denoted by 'keys'
      # to 'values'. Uses setter, when available, otherwise simple
      # 'instance_variable_set' is called. You can specify defaults
      # for your convenience.
      #
      def set_options(options, defaults = {})
        options = defaults.merge(options)
        
        options.each do |attr,value|
          setter = "#{attr}="

          if self.respond_to?(setter)
            self.send(setter, value)
          else
            self.instance_variable_set(attr, value)
          end
        end
      end
        
    end
  end
end
