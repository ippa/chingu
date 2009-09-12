require 'rubygems'
require 'opengl'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu
$stderr.sync = $stdout.sync = true

#
# Testing out a new module-only-super-chain trait system
#
class Game < Chingu::Window
  def initialize
    super(400,400)
    self.caption = "Testing out new module-based traits"
    self.input = { :space => :new_thing, :esc => :exit }
    new_thing(200,200)
  end

  def update
    puts "--- UPDATE ---"
    super
  end
  
  def draw
    puts "--- DRAW ---"
    super
  end
  
  def new_thing(x=nil, y=nil)
    Thing.new(:x => x||rand($window.width), :y => y||rand($window.height))
  end
end

class Thing < Chingu::TraitObject
  has_trait :effect
  has_trait :velocity
  
  def initialize(options)
    super
    @image = Image["spaceship.png"]

    # Julians ninjahack to get that sweet pixely feeling when zooming :)
    glBindTexture(GL_TEXTURE_2D, @image.gl_tex_info.tex_name)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
    
    self.factor = 8
    self.rotating = 2
    self.velocity_x = 2
  end
  
  def update
    puts "Cube#update"
    @velocity_x = -@velocity_x if outside_window?
    super
  end
  
  def draw
    puts "Cube#draw"
    super
  end
  
end


Game.new.show
