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

class Player < GameObject
end



class Game < Chingu::Window
	def initialize
		super(600,200)
		
    player = Player.create
    
  
    Benchmark.bm(22) do |x|
      x.report('create 10000 game objects') { 10000.times { MyGameObject.create } }  
      x.report('update') { 60.times { $window.update } }

      self.input = { :esc => :exit, :d => :exit, :a =>  :exit }
      player.input = { :holding_up => :exit, :holding_down => :exit, :holding_left => :exit, :holding_right => :exit, :space => :exit, :left_ctrl => :exit }
      
      x.report('update window/player input') { 60.times { $window.update } }
    end
	end
end

Game.new.show
