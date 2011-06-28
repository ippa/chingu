class Array
  
  def each_collision(*klasses)
    self.each do |object1|
      object1.each_collision(*klasses) do |object, object2|
        yield object, object2
      end
    end
  end
  
  def each_bounding_circle_collision(*klasses)
    self.each do |object1|
      object1.each_bounding_circle_collision(*klasses) do |object1, object2|
        yield object1, object2
      end
    end    
  end

  def each_bounding_box_collision(*klasses)
    self.each do |object1|
      object1.each_bounding_box_collision(*klasses) do |object1, object2|
        yield object1, object2
      end
    end
  end

  def each_at(x, y)
    self.each do |object|
      object.each_at(x, y) do |obj|
        yield obj
      end
    end
  end

end