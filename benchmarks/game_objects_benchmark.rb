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

class Game < Chingu::Window
	def initialize
		super(600,200)
		self.input = { :esc => :exit }
    
    Benchmark.bm(22) do |x|
      game_object = GameObject.new
      x.report('respond_to?') { 100000.times { game_object.respond_to?(:update_trait) } }
      x.report('call empty method') { 100000.times { game_object.update_trait } }
      
      x.report('game_objects') { 10000.times { GameObject.create } }
      game_objects.clear
      x.report('basic_game_objects') { 10000.times { BasicGameObject.create } }
      game_objects.clear
      x.report('ObjectX') { 10000.times { ObjectX.create } }
      x.report('ObjectY') { 10000.times { ObjectY.create } }
      x.report('ObjectZ') { 10000.times { ObjectZ.create } }
      
      x.report('ObjectX.each') { ObjectX.all.each { |x| } }
      x.report('ObjectY.each') { ObjectY.all.each { |y| } }
      x.report('ObjectZ.each') { ObjectZ.all.each { |z| } }
      
      p game_objects.size
      x.report('ObjectX destroy') { ObjectX.each_with_index { |x, i| x.destroy if i%2==0 }; game_objects.sync; }
      p game_objects.size
    end
    
	end
end

Game.new.show
