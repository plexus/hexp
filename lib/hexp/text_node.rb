module Hexp
  class TextNode < SimpleDelegator
    def inspect
      __getobj__.inspect
    end

    def tree_walk
      yield self
    end

    def attributes
      {}.freeze
    end

    def pp
      inspect
    end

    def filter(*filters, &blk)
      self
    end

    def to_a
      [:text, self, Hexp::List[]]
    end

  end
end
