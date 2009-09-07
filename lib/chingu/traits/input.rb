module Chingu
  module Components
    module Input
    
      def input=(input_map)
        @input = input_map
        @parent.add_input_client(self)  if @parent
      end
      
      def input
        @input
      end
    end
  end
end