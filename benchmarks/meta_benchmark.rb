require 'benchmark'

class A; def meth1; true; end; end

# defining using eval/class/instance
str = "def meth2; true; end"
a_binding = A.send(:binding)

# proc for class/instance
proc1 = Proc.new { def meth2; true; end }

# proc for define_method
$proc2 = Proc.new { true }

# unbound method for bind
um = A.instance_method(:meth1)

# number of iterations
n = 12000 * 600
n = 12000

Benchmark.bm(22) do |x|

  x.report('instance_eval/str') do
    for i in 1..n; A.instance_eval(str); end
  end

  x.report('class_eval/str') do
    for i in 1..n; A.class_eval(str); end
  end

  x.report('eval/str') do
    for i in 1..n; eval(str, a_binding); end
  end

  x.report('define_method/class') do
    for i in 1..n; class A; define_method(:meth2, &$proc2); end; end
  end

  x.report('define_method/send') do
    for i in 1..n; A.send(:define_method, :meth2, &$proc2); end
  end

  x.report('def/unbind/bind') do
    for i in 1..n
      class A; def meth2; true; end; end
      A.instance_method(:meth2).bind(A.new)
    end
  end

  x.report('instance_eval/proc') do
    for i in 1..n; A.instance_eval(&proc1); end
  end

  x.report('class_eval/proc') do
    for i in 1..n; A.class_eval(&proc1); end
  end

  x.report('def') do
    for i in 1..n; class A; def meth2; true; end; end; end
  end

  x.report('method/bind') do
    for i in 1..n; um.bind(A.new); end
  end

end