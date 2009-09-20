require 'rubygems'
require 'opengl'
require 'gosu'
#include Gosu

class Game < Gosu::Window
  def initialize
    super(400,400,false)
  end
  
  def update
  end
  
  def draw
    gl do
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)  

      # Reset the view
      glLoadIdentity

      # Move to the left 1.5 units and into the screen 6.0 units
      glTranslate(-1.5, 0.0, -6.0)

      # -- Draw a triangle --
      glColor(1.0,1.0,1.0)
      
      # Begin drawing a polygon
      glBegin(GL_POLYGON)
         glVertex3f( 0.0, 1.0, 0.0)    # Top vertex
         glVertex3f( 1.0, -1.0, 0.0)    # Bottom right vertex
         glVertex3f(-1.0, -1.0, 0.0)    # Bottom left vertex
      # Done with the polygon
      glEnd

      # Move 3 units to the right
      glTranslate(3.0, 0.0, 0.0)

      # -- Draw a square (quadrilateral) --
      # Begin drawing a polygon (4 sided)
      glBegin(GL_QUADS)
        glVertex3f(-1.0, 1.0, 0.0)       # Top Left vertex
        glVertex3f( 1.0, 1.0, 0.0)       # Top Right vertex
        glVertex3f( 1.0, -1.0, 0.0)      # Bottom Right vertex
         glVertex3f(-1.0, -1.0, 0.0)      # Bottom Left  
      glEnd                
      glFlush
    end
  end  
end

Game.new.show
