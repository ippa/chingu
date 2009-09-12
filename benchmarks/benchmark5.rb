require 'benchmark'
require 'rubygems'
require 'randomr'

class Foo
  def initialize
  end
  
  def bar
  end
end

foo = Foo.new

a = Array.new
n = 1000000
Benchmark.bm(22) do |x|
  x.report('respond_to?') do
    n.times do
      foo.respond_to?(:bar)
    end
  end

  x.report('foo.bar method call') do
    n.times do
      foo.bar
    end
  end
end
