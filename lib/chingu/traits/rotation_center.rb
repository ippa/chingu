module Chingu
  module Traits
    module RotationCenter
      #
      # returns [center_x, center_y] (see Gosu::Image#draw_rot)
      # 
      @@rotation_centers = {
        :top_left => [0,0],
        :left_top => [0,0],
        
        :center_left => [0,0.5],
        :middle_left => [0,0.5],
        :left_center => [0,0.5],
        :left_middle => [0,0.5],
        
        :bottom_left => [0,1],
        :left_bottom => [0,1],
        
        :top_center => [0.5,0],
        :top_middle => [0.5,0],
        :center_top => [0.5,0],
        :middle_top => [0.5,0],
        
        :center_center => [0.5,0.5],
        :middle_middle => [0.5,0.5],
        :center => [0.5,0.5],
        :middle => [0.5,0.5],
        
        :bottom_center => [0.5,1],
        :bottom_middle => [0.5,1],
        :center_bottom => [0.5,1],
        :middle_bottom => [0.5,1],
        
        :top_right => [1,0],
        :right_top => [1,0],
        
        :center_right => [1,0.5],
        :middle_right => [1,0.5],
        :right_center => [1,0.5],
        :right_middle => [1,0.5],
        
        :bottom_right => [1,1],
        :right_bottom => [1,1]
      }
    
      #
      # Sets @center_x and @center_y according to given alignment. Available alignments are:
      #
      #   :top_left, :center_left, :bottom_left, :top_center, 
      #   :center_center, :bottom_center, :top_right, :center_right and :bottom_right
      #
      # They're also available in the opposite order with the same meaning.
      # They're also available (hey, hashlookups are speedy) with "middle" instead of "center" since
      # those 2 words basicly have the same meaning and are both understandable.
      #
      def rotation_center(alignment)
        @center_x, @center_y = @@rotation_centers[alignment.to_sym]
      end
      
    end
  end
end