#!/usr/bin/env ruby
require 'rubygems'
require 'benchmark'
require File.join(File.dirname($0), "..", "lib", "chingu")
#gem 'chingu', '0.6'
#require 'chingu'
include Gosu
include Chingu

class MyGameObject < GameObject
end

class MyBasicGameObject < GameObject
end

class ObjectWithTraits < GameObject
  traits :velocity, :timer
end


class Game < Chingu::Window
	def initialize
		super(600,200)
		self.input = { :esc => :exit }    
  
    Benchmark.bm(22) do |x|
      x.report('create 50000 game objects') { 50000.times { MyGameObject.create } }  
      x.report('force_update') { 60.times { $window.game_objects.force_update } }
      x.report('force_draw') { 60.times { $window.game_objects.force_draw } }      
      x.report('update') { 60.times { $window.game_objects.update } }
      x.report('draw') { 60.times { $window.game_objects.draw } }      
      x.report('update + create') { 60.times { $window.game_objects.update; MyGameObject.create; } }
      x.report('draw + create') { 60.times { $window.game_objects.draw; MyGameObject.create; } }      
      x.report('update + create + destroy') { 60.times { $window.game_objects.update; MyGameObject.create; MyGameObject.all.first.destroy } }
      x.report('draw + create + destroy') { 60.times { $window.game_objects.draw; MyGameObject.create; MyGameObject.all.first.destroy } }
    end
	end
end

Game.new.show

#
# BEFORE GameObjectList visible_game_object/unpaused_game_object - refactor
#
#create 50000 game objects  1.919000   0.000000   1.919000 (  1.906109)
#force_update            0.702000   0.000000   0.702000 (  0.716041)
#force_draw              0.920000   0.000000   0.920000 (  0.924053)
#update                  1.420000   0.000000   1.420000 (  1.421081)
#draw                    1.497000   0.000000   1.497000 (  1.520087)
#update + create         1.420000   0.000000   1.420000 (  1.420081)
#draw + create           1.497000   0.000000   1.497000 (  1.528088)
#update + create + destroy  2.106000   0.000000   2.106000 (  2.099120)
#draw + create + destroy  2.262000   0.000000   2.262000 (  2.265129)

#
# AFTER 
#
#create 50000 game objects  1.934000   0.000000   1.934000 (  1.927111)
#force_update            0.718000   0.000000   0.718000 (  0.712040)
#force_draw              0.920000   0.000000   0.920000 (  0.929053)
#update                  0.702000   0.000000   0.702000 (  0.708041)
#draw                    0.904000   0.000000   0.904000 (  0.932053)
#update + create         0.671000   0.000000   0.671000 (  0.688040)
#draw + create           0.921000   0.000000   0.921000 (  0.915052)
#update + create + destroy  1.950000   0.000000   1.950000 (  1.957112)
#draw + create + destroy  2.184000   0.000000   2.184000 (  2.230128)

#
# CONCLUSION
#
# Even when we're adding or destroying objects each game tick
# we benefit greatly from keeping separate draw and update lists
# instead of checking visible/paused flags in the draw/update loop itself
#