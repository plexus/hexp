module Hexp

  # A Hexp Triplet
  class Triplet < Array

    # Array-style constructor, but normalize the arguments
    #
    # @param args [Array] args a Hexp triplet
    # @return [Hexp::Triplet]
    #
    # @example
    #    Hexp::Triplet[:p, {'class' => 'foo'}, [[:b, "Hello, World!"]]]
    #
    # @api public
    def self.[](*args)
      super(* Normalize.new(args).() )
    end
  end
end
