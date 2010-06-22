class Array
  
  def each_collision(*args)
    list = (self + args).uniq
    collide_pair = []
    list.each_with_index { |nr, i| self[i..size].collect { |nr2| collide_pair << [nr,nr2] } }
    collide_pair.each do |class1,class2|
      class1.each_collision(class2) do |object1, object2|
        yield object1, object2
      end
    end
  end
  
  def each_bounding_circle_collision(*args)
    list = (self + args).uniq
    collide_pair = []
    list.each_with_index { |nr, i| self[i..size].collect { |nr2| collide_pair << [nr,nr2] } }
    collide_pair.each do |class1,class2|
      class1.each_bounding_circle_collision(class2) do |object1, object2|
        yield object1, object2
      end
    end
  end

  def each_bounding_box_collision(*args)
    list = (self + args).uniq
    collide_pair = []
    list.each_with_index { |nr, i| self[i..size].collect { |nr2| collide_pair << [nr,nr2] } }
    collide_pair.each do |class1,class2|
      class1.each_bounding_box_collision(class2) do |object1, object2|
        yield object1, object2
      end
    end
  end

end