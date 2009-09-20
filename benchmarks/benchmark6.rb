require 'benchmark'
require 'rubygems'
require 'set'

a = [1,2,3,4,5]
h = {1=>"b",2=>"b",3=>"b",4=>"b",5=>"b"}

n = 1000000
Benchmark.bm(22) do |x|
  
  x.report('Array.each ') do
    n.times do
      a.each {}
    end
  end
  
  x.report('Hash.each') do
    n.times do
      h.each {}
    end
  end
  
end
