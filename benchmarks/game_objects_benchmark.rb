#!/usr/bin/env ruby
require 'rubygems'
require 'benchmark'
require File.join(File.dirname($0), "..", "lib", "chingu")
#gem 'chingu', '0.6'
#require 'chingu'
include Gosu
include Chingu

class ObjectX < GameObject; end;
class ObjectY < GameObject; end;
class ObjectZ < GameObject; end;
class ObjectWithTraits < GameObject
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
  end
  
  def update
    Benchmark.bm(22) do |x|
      game_object = Test.new
      game_object = GameObject.new
      x.report('respond_to?') { 100000.times { game_object.respond_to?(:update_trait) } }
      x.report('call empty method') { 100000.times { game_object.update_trait } }
      
      x.report('game_objects') { 10000.times { GameObject.create } }
      game_objects.clear
      x.report('basic_game_objects') { 10000.times { BasicGameObject.create } }
      game_objects.clear
      x.report('ObjectX') { 100000.times { ObjectX.create } }
      x.report('ObjectY') { 100000.times { ObjectY.create } }
      x.report('ObjectZ') { 100000.times { ObjectZ.create } }
      x.report('ObjectWithTraits') { 100000.times { ObjectWithTraits.create } }

      x.report('ObjectX full update') { ObjectX.each { |x| x.update_trait; x.update; } }
      x.report('ObjectWithTraits full update') { ObjectWithTraits.each { |x| x.update_trait; x.update; } }

      x.report('ObjectX.each') { ObjectX.all.each { |x| x } }
      x.report('ObjectY.each') { ObjectY.all.each { |y| y } }
      x.report('ObjectZ.each') { ObjectZ.all.each { |z| z } }


      p game_objects.size
      #x.report('ObjectX destroy') { ObjectX.each_with_index { |x, i| x.destroy if i%2==0 }; game_objects.sync; }
      p game_objects.size
      exit
    end
	end
end

Game.new.show


#                            user     system      total        real
#respond_to?             0.015000   0.000000   0.015000 (  0.016001)
#call empty method       0.016000   0.000000   0.016000 (  0.013001)
#game_objects            0.327000   0.000000   0.327000 (  0.329019)
#basic_game_objects      0.047000   0.000000   0.047000 (  0.038002)
#ObjectX                 0.312000   0.000000   0.312000 (  0.314018)
#ObjectY                 0.375000   0.000000   0.375000 (  0.372021)
#ObjectZ                 0.327000   0.000000   0.327000 (  0.335020)
#ObjectWithTraits        0.484000   0.000000   0.484000 (  0.484027)
#ObjectX full update     0.015000   0.000000   0.015000 (  0.012001)
#ObjectWithTraits full update  0.032000   0.000000   0.032000 (  0.034002)
#ObjectX.each            0.015000   0.000000   0.015000 (  0.009000)
#ObjectY.each            0.000000   0.000000   0.000000 (  0.010001)
#ObjectZ.each            0.016000   0.000000   0.016000 (  0.009001)
