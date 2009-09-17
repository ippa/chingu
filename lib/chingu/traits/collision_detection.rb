#--
#
# Chingu -- Game framework built on top of the opengl accelerated gamelib Gosu
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++


module Chingu
  module Traits
    #
    #
    # Use QuadTrees: http://lab.polygonal.de/2007/09/09/quadtree-demonstration/
    #
    # Makes use of 3 attributes
    #   @bounding_box      - a Rect-instance, uses in bounding_box collisions
    #   @radius            -
    #   @detect_collisions - [true|false], should object be checked for collisions with Object.each_collision
    #
    module CollisionDetection
      attr_accessor :bounding_box, :radius, :detect_collisions
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      #
      # Automaticly try to set a bounding_box and radius. Don't overwrite if they already exists.
      #
      def setup_trait(options)
        if @x and @y and @image
          @bounding_box ||= Rect.new(@x, @y, @image.width, @image.height)
        end
        
        if @image
          @radius ||= @image.width / 2
        end
        
        @detect_collisions = true
        super
      end
      
      #
      # The standard method called when self needs to be checked for a collision with another object
      # By default it calls bounding_box_collision? which will check for intersectons between the 
      # two objects "bounding_box" attributs (a Chingu::Rect instance)
      #
      def collision?(object2)
        #bounding_box_collision?(object2)
        radius_collision?(object2)
      end
      
      #
      # Collide self with a given game object by checking both objects bounding_box'es
      # Returns true if colliding.
      #
      def bounding_box_collision?(object2)
        self.bounding_box.collide_rect?(object2.bounding_box)
      end
      
      #
      # Collide self using distance between 2 objects and their radius.
      # Returns true if colliding.
      #
      def radius_collision?(object2)
        distance(self.x, self.y, object2.x, object2.y) < self.radius + object2.radius
      end
      
      #
      # Have bounding box follow game objects x/y
      #
      def update
        if defined?(@bounding_box) && @bounding_box.is_a?(Rect)
          @bounding_box.x = self.x
          @bounding_box.y = self.y
        end
        
        super
      end

      
      module ClassMethods
        #
        # Class method that will check for collisions between all instances of two classes
        # and yield the 2 colliding game object instances.
        #
        # It will not collide objects with themselves.
        #
        #   example:
        #
        #   Enemy.each_collision(Bullet).each do |enemy, bullet| enemy.die!; end
        #
        #
        def each_collision(klasses = [])
          # Make sure klasses is always an array.
          Array(klasses).each do |klass|
            self.all.each do |object1|
              klass.all.each do |object2|
                next  if object1 == object2  # Don't collide objects with themselves
                
                if object1.detect_collisions && object2.detect_collisions
                  yield object1, object2  if object1.collision?(object2)
                end
              end
            end
          end
        end
      end
      
    end
  end
end