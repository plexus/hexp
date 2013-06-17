module Hexp
  # A list of nodes
  #
  #
  class List < SimpleDelegator
    include Equalizer.new(:__getobj__)

    # Create new Hexp::List
    #
    # @example
    #   Hexp::List.new([H[:p], H[:div]])
    #
    # @param nodes [#to_ary] List of nodes
    #
    # @api public
    #
    def initialize(nodes)
      super Hexp.deep_freeze nodes.to_ary
    end

    # Convenience constructor
    #
    # @example
    #   Hexp::List[
    #     Hexp::Node[:marquee, "Try Hexp for instanst satisfaction!"],
    #     Hexp::Node[:hr],
    #   ]
    #
    # @param args [Array] individual nodes
    #
    # @api public
    #
    def self.[](*args)
      new(args)
    end

    # String representation
    #
    # This delegates to the underlying array, so it's not obvious from the output
    # that this is a wrapping class. This is convenient when inspecting nested
    # hexps, but probably something we want to solve differently.
    #
    # @api private
    # @return string
    #
    def inspect
      __getobj__.inspect
    end

    def to_ary
      __getobj__
    end
  end
end
