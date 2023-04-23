require 'benchmark'
require 'rubygems'
# require 'randomr'

a = Array.new
n = 1000000
Benchmark.bm(22) do |x|
  x.report('is_a?') do
    n.times do
      a.is_a?(Array)
    end
  end

  x.report('kind_of?') do
    n.times do
      a.kind_of?(Array)
    end
  end

  x.report('respond_to?') do
    n.times do
      a.respond_to?(:size)
    end
  end
end



arr = [:a, :b, :c]
n = 1000000
Benchmark.bm(22) do |x|
  x.report('arr.each') do
    n.times do
      arr.each { |item| item; }
    end
  end
  
  x.report('for item in arr') do
    n.times do
      for item in arr; item; end;
    end
  end
end


n = 1000000
Benchmark.bm(22) do |x|
  x.report('randomr(100)') do
    for i in 1..n; rand; end
  end
  
  x.report('rand(100)') do
    for i in 1..n; rand(100); end
  end
end


n = 1000000
Benchmark.bm(12) do |test|
  test.report("normal:")    do
    n.times do |x|
      y = x + 1
    end
  end
  test.report("predefine:") do
    x = y = 0
    n.times do |x|
      y = x + 1
    end
  end
end