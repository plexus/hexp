if defined?(::H) && ::H != Hexp::Node
  $stderr.puts "WARN: H is already defined, Hexp H[] shorthand not available"
else
  module H
    def self.[](*args)
      if args.first.is_a? Symbol
        Hexp::Node[*args]
      else
        Hexp::List[*args]
      end
    end
  end
end
