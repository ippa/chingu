require 'benchmark'

class A
    attr_reader :variable
    def initialize
      @variable = "hello"
    end
end

a = A.new
# number of iterations
n = 1000000

Benchmark.bm(22) do |x|
  x.report('getter') do
    for i in 1..n; a.variable; end
  end

  x.report('direct access') do
    @variable = "hello"
    for i in 1..n; @variable; end
  end
end