class Range
  
  INTERPOLATE_FUNCTIONS = [ :linear, :geometric ]
  
  #
  # Interpolates a value between
  #
  def interpolate t
    # TODO possibly allow geometric or arbitrary interpolation
    a,  b  = self.begin, self.end
    ta, tb = (1.0 - t), t
    a * ta  + b * tb
  end
  
end