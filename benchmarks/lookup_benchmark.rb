require 'benchmark'

Benchmark.bm(22) do |x|
  @map = Array.new
  @map[0] = Array.new
  @map[0][0] = "item"
  x.report('lookup fail exception') { 1000000.times { @map[0][10]  rescue nil } }
  x.report('lookup fail') { 1000000.times { @map[0] && @map[0][10]  } }
end