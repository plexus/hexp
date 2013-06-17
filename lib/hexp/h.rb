if defined?(::H) && ::H != Hexp::Node
  $stderr.puts "WARN: H is already defined, Hexp H[] shorthand not available"
else
  H=Hexp::Node
end
