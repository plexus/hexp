module Hexp
  # Represents text inside HTML, at the moment a wrapper
  # around a plain String. Needs work
  class TextNode < SimpleDelegator
    def inspect
      __getobj__.inspect
    end

    def attributes
      {}.freeze
    end

    def pp
      inspect
    end
  end
end
