require 'benchmark'

class A; def meth1; true; end; end

# defining using eval/class/instance
str = "@var = 1"
a_binding = A.send(:binding)

# proc for class/instance
proc1 = Proc.new { def meth2; true; end }

# proc for define_method
$proc2 = Proc.new { true }

# unbound method for bind
um = A.instance_method(:meth1)

# number of iterations
n = 5 * 60 * 10

Benchmark.bm(22) do |x|

  x.report('straight set') do
    for i in 1..n; @var = 1; end
  end

  x.report('instance_eval/str') do
    for i in 1..n; A.instance_eval(str); end
  end

  x.report('class_eval/str') do
    for i in 1..n; A.class_eval(str); end
  end

  x.report('eval/str') do
    for i in 1..n; eval(str, a_binding); end
  end

end