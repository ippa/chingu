#!/usr/bin/env ruby
require 'rubygems'
require 'benchmark'
a = []
aa = []
b = []
bb = []
1000.times do |index|
  a.push(index)
  b.push(index) if index%2 == 0
  aa.push(index)
  bb.push(index) if index%2 == 0
end
p a.size
p aa.size

Benchmark.bm(22) do |x|
  x.report('remove b from a #1') { b.each { |x| a.delete(x) }; }
  p a.size
  x.report('remove b from a #2') { aa -= bb; }
  p aa.size
end