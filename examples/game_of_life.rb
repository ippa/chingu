#
# Conway's game of life in Gosu/Chingu
# http://toastymofo.blogspot.com/2010/06/conways-game-of-life-in-ruby-gosu.html
# 
# Developed by r.kachowski ( http://www.toastymofo.net/ )
#
require 'chingu'
require 'gosu'

class Main < Chingu::Window
  def initialize
    super(640,480,false)
    self.input={:esc=>:exit}    
    push_game_state(GameOfLife)
  end
  def draw
    super
    fill_rect([0,0,640,480], 0xffffffff, -2)
  end
end

class GameOfLife < Chingu::GameState
  CELL_SIZE = 4
  @@tick =0
  def initialize
    super
    @grid = generate_grid
    self.input={:left_mouse_button=>:set_grid_block,:space=>:toggle_running,
      :right_mouse_button=>:unset_grid_block,:z=>:reset}
    @running = false
    
  end  
  
  def update
    super
    update_grid if @running

    $window.caption = "conway generation #{@@tick}"
  end

  def draw
    super
    draw_grid
    draw_mouse
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
    @@tick =0
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

        if live_neighbours == 4 || live_neighbours < 2
          @new_grid[x][y] = false
        end
        
        if live_neighbours == 3 then @new_grid[x][y] = true end

      end
    end

    @grid = @new_grid
    @@tick+=1
  end

  def toggle_running
    @running = !@running
  end

  def set_grid_block
    
    x = ($window.mouse_x/CELL_SIZE).floor
    y = ($window.mouse_y/CELL_SIZE).floor
    
    @grid[x][y]=true
    
  end

  def unset_grid_block
    x = ($window.mouse_x/CELL_SIZE).floor
    y = ($window.mouse_y/CELL_SIZE).floor

    @grid[x][y]=false
  end
  def draw_mouse
    $window.fill_rect([($window.mouse_x/CELL_SIZE).floor*CELL_SIZE,($window.mouse_y/CELL_SIZE).floor*CELL_SIZE,CELL_SIZE,CELL_SIZE],0xaa0000ff,0)
  end
end

Main.new.show