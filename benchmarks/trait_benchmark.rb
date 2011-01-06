#!/usr/bin/env ruby
require 'rubygems'
require 'benchmark'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

# This includes trait :sprite
class SimpleGameObject < BasicGameObject
  trait :simple_sprite
end

class ObjectX < GameObject
  traits :velocity, :timer
end

class Test
  @instances = [] 
  class << self; attr_accessor :instances end
  
  def initialize
    self.class.instances << self
  end
end

class Game < Chingu::Window
	def initialize
		super(600,200)
		self.input = { :esc => :exit }    
    
    Benchmark.bm(22) do |x|
      #x.report('GameObject.destroy_all') { GameObject.destroy_all }     # SLOW!
      x.report('SimpleameObject.create') { 50000.times { SimpleGameObject.create } }      
      x.report('GameObject.create') { 50000.times { GameObject.create } }
      x.report('GameObject.create') { 50000.times { GameObject.create } }
      x.report('GameObject.create') { 50000.times { GameObject.create } }
    end
    
  end
  
end

Game.new.show


# 50000 x GameObject

#
# With set_options()
#                            user     system      total        real
#GameObject.create       1.825000   0.000000   1.825000 (  1.824104)
#GameObject.create       2.044000   0.016000   2.060000 (  2.083119)
#GameObject.create       1.934000   0.000000   1.934000 (  1.996114)

#
# With oldschool option-parsing
#
#                            user     system      total        real
#GameObject.create       0.577000   0.000000   0.577000 (  0.574033)
#GameObject.create       0.577000   0.015000   0.592000 (  0.599034)
#GameObject.create       0.624000   0.000000   0.624000 (  0.623036)