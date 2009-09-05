module Chingu
  module Components
    #
    # TODO: everything. convert to class?
    #
    module CollisionDetection
    
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      def collision?(object2)
        self.rect.collide_rect?(object2.rect)
      end
      
      module ClassMethods
        def each_collision(klasses = [])
          # Make sure klasses is always an array.
          Array(klasses).each do |klass|
            self.all.each do |object1|
              klass.all.each do |object2|
                yield object1, object2  if object1.collision?(object2)
              end
            end
          end
        end
      end
      
    end
  end
end