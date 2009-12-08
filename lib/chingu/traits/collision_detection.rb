#--
#
# Chingu -- OpenGL accelerated 2D game framework for Ruby
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
    # Research:
    # 1) QuadTrees: http://lab.polygonal.de/2007/09/09/quadtree-demonstration/
    # 2) Sweep and Prune
    #
    # SEE: http://www.shmup-dev.com/forum/index.php?board=65.0
    #
    # Makes use of 2 attributes
    #   bounding_box      - a Rect-instance, uses in bounding_box collisions
    #   radius            - a number
    #
    module CollisionDetection
      
      module ClassMethods
        def initialize_trait(options = {})
          trait_options[:collision_detection] = options
        end
      end
      
      #
      # The standard method called when self needs to be checked for a collision with another object
      # By default it calls bounding_box_collision? which will check for intersectons between the 
      # two objects "bounding_box" attributs (a Chingu::Rect instance)
      #
      def collides?(object2)
        if self.respond_to?(:bounding_box) && object2.respond_to?(:bounding_box)
          bounding_box_collision?(object2)
        elsif self.respond_to?(:radius) && object2.respond_to?(:radius)
          bounding_circle_collision?(object2)
        else
          bounding_box_bounding_circle_collision?(object2)
        end
      end
      alias :collision? :collides?
      
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
      def bounding_circle_collision?(object2)
        Gosu.distance(self.x, self.y, object2.x, object2.y) < self.radius + object2.radius
      end
      
      #
      # BoundingBox vs Radius collision
      #
      # http://stackoverflow.com/questions/401847/circle-rectangle-collision-detection-intersection
      #
      def bounding_box_bounding_circle_collision?(object2)
        rect = self.respond_to?(:bounding_box) ? self.bounding_box : object2.bounding_box
        circle = self.respond_to?(:radius) ? self : object2
        radius = circle.radius.to_i
        
        distance_x = (circle.x - rect.x - rect.width/2).abs
        distance_y = (circle.y - rect.y - rect.height/2).abs
        
        return false if distance_x > (rect.width/2 + circle.radius)
        return false if distance_y > (rect.height/2 + circle.radius)
        
        return true if distance_x <= (rect.width/2)
        return true if distance_y <= (rect.height/2)
          
        cornerDistance_sq = (distance_x - rect.width/2) ** 2 + (distance_y - rect.height/2) ** 2
        return (cornerDistance_sq <= (circle.radius ** 2))
      end
        
      #
      # Collides self with all objects of given classes
      # Yields self and the objects it collides with
      #
      def each_collision(*klasses)
        Array(klasses).each do |klass|
          klass.all.each do |object|
            yield(self, object)   if collides?(object)
          end
        end
      end
      
      #
      # Explicit radius-collision
      # Works like each_collsion but with inline-code for speedups
      #
      def each_bounding_circle_collision(klasses = [])
        Array(klasses).each do |klass|
          klass.all.each do |object|
            yield(self, object) if Gosu.distance(self.x, self.y, object.x, object.y) < self.radius + object.radius
          end
        end
      end

      #
      # Explicit bounding_box-collision
      # Works like each_collision but with inline-code for speedups
      #
      def each_bounding_box_collision(klasses = [])
        Array(klasses).each do |klass|
          klass.all.each do |object|
            yield(self, object) if self.bounding_box.collide_rect?(object.bounding_box)
          end
        end
      end

      
      module ClassMethods
        #
        # Works like each_collision but with inline-code for speedups
        #
        def each_bounding_circle_collision(klasses = [])
          Array(klasses).each do |klass|
            object2_list = klass.all
            #total_radius = object1.radius + object2.radius  # possible optimization?
            
            self.all.each do |object1|
              object2_list.each do |object2|
                next  if object1 == object2  # Don't collide objects with themselves
                yield object1, object2  if Gosu.distance(object1.x, object1.y, object2.x, object2.y) < object1.radius + object2.radius
              end
            end
          end
        end
        
        #
        # Works like each_collsion but with explicit bounding_box collisions (inline-code for speedups)
        #
        def each_bounding_box_collision(klasses = [])
          Array(klasses).each do |klass|
            object2_list = klass.all
            self.all.each do |object1|
              object2_list.each do |object2|
                next  if object1 == object2  # Don't collide objects with themselves
                yield object1, object2  if object1.bounding_box.collide_rect?(object2.bounding_box)
              end
            end
          end
        end
        
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
        def each_collision(*klasses)
          # Make sure klasses is always an array.
          Array(klasses).each do |klass|
            
            if self.instance_methods.include?(:radius) && klass.instance_methods.include?(:radius)
              self.each_bounding_circle_collision(klass) do |o1, o2|
                yield o1, o2
              end
              next
            end
                
            if self.instance_methods.include?(:bounding_box) && klass.instance_methods.include?(:bounding_box)
              self.each_bounding_box_collision(klass) do |o1, o2|
                yield o1, o2
              end
              next
            end
              
            #
            # Possible optimization, look into later.
            #
            # type1 = self.instance_methods.include?(:bounding_box) ? :bb : :bc
            # type2 = klass.instance_methods.include?(:bounding_box) ? :bb : :bc
            # Pointless optmization-attempts?
            #if type1 != type2
            #  self.all.each do |object1|
            #    object2_list.each do |object2|
            #      next  if object1 == object2  # Don't collide objects with themselves
            #      yield object1, object2  if object1.bounding_box_bounding_circle_collision?(object2)
            #    end
            #  end
            #end
            object2_list = klass.all
            self.all.each do |object1|
              object2_list.each do |object2|
                next  if object1 == object2  # Don't collide objects with themselves
                yield object1, object2  if object1.collides?(object2)
              end
            end
          end
        end
      end
    end
  end
end