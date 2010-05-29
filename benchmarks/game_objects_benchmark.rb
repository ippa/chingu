#!/usr/bin/env ruby
require 'rubygems'
require 'benchmark'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu


class Game < Chingu::Window
	def initialize
		super(600,200)
		self.input = { :esc => :exit }
		@iterations = 10
	end
	
	def update
		if @iterations > 0
			create_objects
			@iterations -= 1
		end		
	end
	
	def create_objects
		Benchmark.bm(22) do |x|
			x.report('create') do
				100000.times do
					MyGameObject.create					
				end
			end
		end
	end
end

class MyGameObject < Chingu::GameObject
end

Game.new.show


# 100000 MyGameObject.create with add_game_objects / remove_game_objects -arrays
#                              user     system      total        real
#create                  0.951000   0.047000   0.998000 (  0.998057)
#create                  1.139000   0.031000   1.170000 (  1.155066)
#create                  1.186000   0.047000   1.233000 (  1.239071)
#create                  1.528000   0.000000   1.528000 (  1.520087)
#create                  1.451000   0.031000   1.482000 (  1.488085)
#create                  1.654000   0.016000   1.670000 (  1.662095)
#create                  1.794000   0.015000   1.809000 (  1.819104)
#create                  1.997000   0.000000   1.997000 (  1.986114)
#create                  1.934000   0.000000   1.934000 (  1.930110)
#create                  2.075000   0.000000   2.075000 (  2.087119)