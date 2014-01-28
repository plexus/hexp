require 'benchmark/ips'

def ten_times_ten(depth = 10)
  if depth == 0
    H[:foo]
  else
    H[:foo, [ten_times_ten(depth - 1)] * 10]
  end
end


Benchmark.ips do |x|
  big_tree = ten_times_ten

  x.report('rewrite') do
    big_tree.rewrite {|x| x}
  end

  x.report('add_class') do
    big_tree.rewrite {|x| x.add_class('hello')}
  end

end
