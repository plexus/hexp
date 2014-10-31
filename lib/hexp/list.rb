module Hexp
  # A list of nodes
  #
  class List < DelegateClass(Array)
    include Adamantium

    # Create new Hexp::List
    #
    # @example
    #   Hexp::List.new([H[:p], H[:div]])
    #
    # @param [#to_ary] nodes
    #   List of nodes
    #
    # @api public
    def initialize(nodes)
      super nodes.to_ary.map(&Node::Normalize.method(:coerce_node)).freeze
    end

    # Convenience constructor
    #
    # @example
    #   Hexp::List[
    #     Hexp::Node[:marquee, "Try Hexp for instanst satisfaction!"],
    #     Hexp::Node[:hr],
    #   ]
    #
    # @param [Array] args
    #   individual nodes
    #
    # @return [Hexp::List]
    #
    # @api public
    def self.[](*args)
      new(args)
    end

    # String representation
    #
    # This delegates to the underlying array, so it's not obvious from the output
    # that this is a wrapping class. This is convenient when inspecting nested
    # hexps, but probably something we want to solve differently.
    #
    # @return [String]
    #
    # @api private
    def inspect
      __getobj__.inspect
    end

    # Implicit conversion to Array
    #
    # @example
    #   Hexp::List[ H[:p], H[:span] ].to_ary #=> [H[:p], H[:span]]
    #
    # @return [Array<Hexp::Node>]
    #
    # @api public
    def to_ary
      __getobj__
    end

    # Value and type equality
    #
    # Hexp::List is mostly interchangeable with a plain Array, and so equality
    # with `==` delegates to the underlying array, making `Hexp::List[] == []`
    # true.
    #
    # If you want a stronger comparison, than this version will compare both
    # the value (in this case : contents), and the type.
    #
    # @example
    #   H[:div, [[:span]]].children == [H[:span]]             #=> true
    #   H[:div, [[:span]]].children.eql? [H[:span]]           #=> false
    #   H[:div, [[:span]]].children.eql? Hexp::List[H[:span]] #=> true
    #
    # @param [Object] other
    #   Object to compare with
    #
    # @return [true,false]
    #
    # @api public
    def eql?(other)
      self == other && self.class == other.class
    end

    def to_html
      each_with_object('') {|n,s| s << n.to_html}
    end

    def +(other)
      self.class[*to_ary, *other.to_ary]
    end

    def append(*args)
      self + args
    end
  end
end
