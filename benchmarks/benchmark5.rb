require 'benchmark'
require 'rubygems'
require 'set'

class Foo
  @list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  @@list2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  
  def self.list
    @list
  end

  def self.list2
    @@list2
  end

  attr_accessor :list
  def initialize
    @list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  end
  
  def bar
  end
end

foo = Foo.new


s = Set.new
a = Array.new

n = 1000000
Benchmark.bm(22) do |x|
  
  x.report('Array << ') do
    n.times do
      a << n
    end
  end
  
  x.report('Set << ') do
    n.times do
      s << n
    end
  end
  
end



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

n = 100000
Benchmark.bm(22) do |x|
  x.report('ivar axx') do
    n.times do
      foo.list.each { |num| }
    end
  end

  x.report('class attribute axx') do
    n.times do
      Foo.list.each { |num| }
    end
  end
  
  x.report('class var axx') do
    n.times do
      Foo.list2.each { |num| }
    end
  end  
end