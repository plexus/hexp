module Hexp
  module CssSelector
    module Members
      include Equalizer.new(:members)
      attr_reader :members

      def initialize(members)
        @members = Hexp.deep_freeze(members)
      end

      def self.included(klz)
        def klz.[](*members)
          new(members)
        end
      end
    end

    module Named
      include Equalizer.new(:name)
      attr_reader :name

      def initialize(name)
        @name = name.freeze
      end
    end

    class CommaSequence  ; include Members ;  end
    class Sequence       ; include Members ;  end
    class SimpleSequence ; include Members ;  end

    class Class          ; include Named   ; end
    class Element        ; include Named   ; end

  end
end
