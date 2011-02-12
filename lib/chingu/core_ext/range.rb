class Range
  
  #
  # Linearly interpolates a value between begin and end.
  #
  def interpolate(t)
    # TODO possibly allow geometric or arbitrary interpolation
    a,  b  = self.begin, self.end
    ta, tb = (1.0 - t), t
    a * ta  + b * tb
  end
  
end
