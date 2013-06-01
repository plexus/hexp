module Hexp
  # A list of nodes
  #
  # @example
  #   Hexp::List[
  #     Hexp::Node[:marquee, "Try Hexp for instanst satisfaction!"],
  #     Hexp::Node[:hr],
  #   ]
  #
  class List < SimpleDelegator
    include Equalizer.new(:__getobj__)

    def initialize(nodes)
      super Hexp.deep_freeze nodes
    end

    def self.[](*args)
      new(args)
    end

    def inspect
      __getobj__.inspect
    end
  end
end
