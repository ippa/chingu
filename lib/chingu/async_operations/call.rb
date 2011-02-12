module Chingu
  module AsyncOperations
    
    #
    # Single method call as an asynchronous operation.
    #
    class Call < BasicOp
      
      def initialize(owner, method, *args, &callback)
        super owner, &callback
        @method, @args = method, args
      end
      
      def update
        finish @owner.__getobj__.send(@method, *@args)
      end
      
    end
    
  end
end
