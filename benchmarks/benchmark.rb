require 'benchmark'
Benchmark.bm do |b|
  range = 1..10000
  b.report("Object") {range.each {Object.new}}
  b.report("BasicObject") {range.each {Array.new}}
end