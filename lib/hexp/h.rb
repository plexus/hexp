require 'hexp'

if defined?(::H) && ::H != Hexp::Node
  STDERR.puts "WARN: H is already defined, Hexp H[] shorthand not available"
else
  H=Hexp::Node
end
