#
# Conway's game of life in Gosu/Chingu
# http://toastymofo.blogspot.com/2010/06/conways-game-of-life-in-ruby-gosu.html
# 
# Developed by r.kachowski ( http://www.toastymofo.net/ )
# Additions by ippa ( http://ippa.se/gaming )
#
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'

class Main < Chingu::Window
  def initialize
    super(640,480,false)
    self.input={:esc=>:exit}    
    push_game_state(GameOfLife)
  end
  def draw
    fill_rect([0,0,640,480], 0xffffffff, -2)
    super
  end
end

class GameOfLife < Chingu::GameState
  CELL_SIZE = 4
  @@tick =0
  def initialize
    super
    @grid = generate_grid
    
    self.input={  :left_mouse_button => :start_painting, 
                  :released_left_mouse_button => :stop_painting,
                  :right_mouse_button => :start_erasing,
                  :released_right_mouse_button => :stop_erasing,
                  :z => :reset,
                  :n => :update_grid,
                  :space => :toggle_running,
                  [:mouse_wheel_up,:left_arrow] => :prev_pattern,
                  [:mouse_wheel_down,:right_arrow] => :next_pattern
                }

    @pattern = :pixel
    @pattern_nr = 0
    @painting = false
    @erasing = false
    @running = false
    
    @pattern_info = Chingu::Text.create(:x => 1, :y => 1, :size => 16, :color => Gosu::Color::BLACK)
    update_pattern_info
  end  
  
  def update_pattern_info
    @pattern_info.text = "Current pattern: #{@pattern}. Change patterns with mousewheel."
  end
    
  def prev_pattern
    @pattern_nr -= 1
    @pattern_nr = PATTERNS.keys.size-1 if @pattern_nr < 0
    @pattern = PATTERNS.keys[@pattern_nr]
    update_pattern_info
  end
  
  def next_pattern
    @pattern_nr += 1
    @pattern_nr = 0 if @pattern_nr >= PATTERNS.keys.size
    @pattern = PATTERNS.keys[@pattern_nr]
    update_pattern_info
  end
  
  def draw_pattern_at_mouse(pattern = :pixel, to_grid = false)
    start_x = ($window.mouse_x/CELL_SIZE).floor
    y = ($window.mouse_y/CELL_SIZE).floor - 1
    
    PATTERNS[pattern].each_line do |line|
      x = start_x
      line.each_char do |char|
        @grid[x][y] = true  if char == "o" && to_grid
        draw_cell(x, y)     if char == "o"
        x += 1
      end
      
      y += 1
    end
  end
  
  def update
    super
        
    update_grid if @running
    
    $window.caption = "Conway Generation #{@@tick}. Start/Stop with 'Space'. Run 1 generation with 'N'. Reset with 'Z'."
  end

  def draw
    super
    
    draw_grid
    
    if @painting
      draw_pattern_at_mouse(@pattern, true)
      @painting = false if  @running           # Only put out pattern Once if game is running
    else
      draw_pattern_at_mouse(@pattern)
    end
    
  end
  
  private

  def generate_grid
    width = $window.width/CELL_SIZE
    height = $window.height/CELL_SIZE

    grid = Array.new(width)
    col = Array.new(height)    
    col.map!{false}
    grid.map!{Array.new(col)}
    grid
  end

  def draw_grid
    @grid.each_with_index do |a,x|
      a.each_with_index do |c,y|
        if c === true
          $window.fill_rect([x*CELL_SIZE,y*CELL_SIZE,CELL_SIZE,CELL_SIZE],0xff000000,0)
        end        
      end
    end
  end

  def reset
    @grid = generate_grid
    @@tick = 0
    @running = false
  end

  def update_grid
    @new_grid = Marshal.load(Marshal.dump(@grid))

    @grid.each_with_index do |a,x|
      a.each_with_index do |c,y|
        minus_x =x-1
        minus_y = y-1
        plus_x = x+1
        plus_y = y+1
        minus_x = @grid.length-1 if minus_x <0
        minus_y = a.length-1 if minus_y <0
        plus_y = 0 if plus_y >= a.length
        plus_x = 0 if plus_x >= @grid.length

        live_neighbours = 0

        @grid[minus_x][y] == true ? live_neighbours+=1 : nil
        @grid[plus_x][y] == true ? live_neighbours+=1 : nil
        @grid[x][minus_y] == true ? live_neighbours+=1 : nil
        @grid[x][plus_y] == true ? live_neighbours+=1 : nil
        @grid[minus_x][plus_y] == true ? live_neighbours+=1 : nil
        @grid[plus_x][minus_y] == true ? live_neighbours+=1 : nil
        @grid[minus_x][minus_y] == true ? live_neighbours+=1 : nil
        @grid[plus_x][plus_y] == true ? live_neighbours+=1 : nil

        case live_neighbours
          when 0..1 then @new_grid[x][y] = false
          when 2 then @new_grid[x][y] = true if @new_grid[x][y] == true
          when 3 then @new_grid[x][y] = true
          when 4..8 then @new_grid[x][y] = false
        end

      end
    end

    @grid = @new_grid
    @@tick+=1
  end

  def toggle_running
    @running = !@running
  end
  
  def start_painting; @painting = true; end
  def stop_painting;  @painting = false; end  
  def start_erasing;  @erasing = true; end
  def stop_erasing;   @erasing = false; end
      
  def draw_cell(x, y, color = 0xaaff0000)
    $window.fill_rect([x*CELL_SIZE,y*CELL_SIZE,CELL_SIZE,CELL_SIZE],0xaa0000ff,1)
  end
  
end


PATTERNS = Hash.new

PATTERNS[:pixel] = %q{
o
}

#
# Spaceships
#
PATTERNS[:glider] = %q{
---o
-o-o
--oo
}

PATTERNS[:lightweight_spaceship] = %q{
-oooo
o---o
----o
o--o-
}

#
# Oscillators
#
PATTERNS[:blinker] = %q{
ooo
}

PATTERNS[:beacon] = %q{
-ooo
ooo-
}

PATTERNS[:toad] = %q{
oo--
o---
---o
--oo
}

PATTERNS[:pulsar] = %q{
---ooo---ooo--
--------------
-o----o-o----o
-o----o-o----o
-o----o-o----o
---ooo---ooo--
--------------
---ooo---ooo--
-o----o-o----o
-o----o-o----o
-o----o-o----o
--------------
---ooo---ooo--
}

#
# Guns
#
PATTERNS[:gospel_glider_gun] = %q{
------------------------o-----------
----------------------o-o-----------
------------oo------oo------------oo
-----------o---o----oo------------oo
oo--------o-----o---oo--------------
oo--------o---o-oo----o-o-----------
----------o-----o-------o-----------
-----------o---o--------------------
------------oo----------------------
}

PATTERNS[:block_laying_switch_engine] = %q{
----------o-o--
oo-------o-----
oo--------o--o-
------------ooo
}



#
# Long lived patterns
#
PATTERNS[:rpentomino] = %q{
--oo
-oo
--o
}

PATTERNS[:diehard] = %q{
oo---o-o
oo----o-
------o-
}

PATTERNS[:acorn] = %q{
--o-----
----o---
-oo--ooo
}

Main.new.show