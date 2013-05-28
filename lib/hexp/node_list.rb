module Hexp
  class NodeList < SimpleDelegator
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
