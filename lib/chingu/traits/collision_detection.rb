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
    # Research:
    # 1) QuadTrees: http://lab.polygonal.de/2007/09/09/quadtree-demonstration/
    # 2) Sweep and Prune
    #
    # SEE: http://www.shmup-dev.com/forum/index.php?board=65.0
    #
    # Makes use of 3 attributes
    #   @bounding_box      - a Rect-instance, uses in bounding_box collisions
    #   @radius            -
    #   @detect_collisions - [true|false], should object be checked for collisions with Object.each_collision
    #
    module CollisionDetection
      attr_accessor :bounding_box, :radius
      ## attr_accessor :detect_collisions # slowed down example9 with 3 fps
      
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
          @radius ||= (@image.height + @image.width) / 2 * 0.80
        end
        
        ## @detect_collisions = true
        super
      end
      
      #
      # The standard method called when self needs to be checked for a collision with another object
      # By default it calls bounding_box_collision? which will check for intersectons between the 
      # two objects "bounding_box" attributs (a Chingu::Rect instance)
      #
      def collides?(object2)
        bounding_box_collision?(object2)
        #radius_collision?(object2)
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
      def update_trait
        if defined?(@bounding_box) && @bounding_box.is_a?(Rect)
          @bounding_box.x = self.x
          @bounding_box.y = self.y
        end
        
        super
      end

      #
      # Collides self with all objects of given classes
      # Yields self and the objects it collides with
      #
      def each_collision(klasses = [])
        Array(klasses).each do |klass|        
          klass.all.each do |object|
            yield(self, object)   if collides?(object)
          end
        end
      end
      
      #
      # Works like each_collsion but with inline-code for speedups
      #
      def each_radius_collision(klasses = [])
        Array(klasses).each do |klass|
          klass.all.each do |object|
            yield(self, object) if distance(@x, @y, object.x, object.y) < @radius + object.radius
          end
        end
      end


      
      module ClassMethods
      
        #
        # Works like each_collsion but with inline-code for speedups
        #
        def each_radius_collision(klasses = [])
          Array(klasses).each do |klass|
            object2_list = klass.all
            #total_radius = object1.radius + object2.radius  # possible optimization?
            
            self.all.each do |object1|
              object2_list.each do |object2|
                next  if object1 == object2  # Don't collide objects with themselves
                yield object1, object2  if distance(object1.x, object1.y, object2.x, object2.y) < object1.radius + object2.radius
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
        def each_collision(klasses = [])
          # Make sure klasses is always an array.
          Array(klasses).each do |klass|
            object2_list = klass.all
            
            self.all.each do |object1|
              object2_list.all.each do |object2|
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