module Hexp

  # A Hexp Triplet
  class Triplet < Array

    # Array-style constructor, but normalize the arguments
    # @param args [Array] args a Hexp triplet
    # @return [Hexp::Triplet]
    # @example
    #    Hexp::Triplet[:p, {'class' => 'foo'}, [[:b, "Hello, World!"]]]
    # @api public
    def self.[](*args)
      super(*normalize(args))
    end

    # Normalize to strict hexp triplets, cfr SPEC.md for details
    # @param args [Array] non-strict hexp
    # @return [Array] strict hexp triplet
    # @api private
    def self.normalize(args)
      attrs, args = extract_attributes(args)
      children    = extract_children(args)
      children    = normalize_children(children)
      [args.first, attrs, children]
    end

    # Pulls the attributes hash out of a non-strict hexp
    # @param args [Array] the arguments as given to Hexp::Triplet.[]
    # @return [Hash, Array] the attributes hash, and the arguments with the
    #         attributes hash taken out
    # @api private
    def self.extract_attributes(args)
      second = args[1]
      if second.instance_of?(Hash)
        [ second, [args.first, *args[2..-1]]]
      else
        [ {}, args ]
      end
    end

    # Pulls the children list out of a non-strict hexp
    # @param args [Array] the arguments as given to Hexp::Triplet.[]
    # @return [Array] the list of child hexps, non-strict
    # @api private
    def self.extract_children(args)
      children = args[1]
      if children.instance_of?(Array) || children.instance_of?(String)
        children
      else
        []
      end
    end

    # Normalize the third element of a hexp triplet, the list of children
    # @param children [Array|String] List of children, or string if the only
    #        child is a text node
    # @return [Array]
    # @api private
    def self.normalize_children(children)
      case children
      when String
        [ children ]
      when Array
        children.map do |child|
          case child
          when String
            child
          when Array
            Hexp::Triplet[*child]
          else
            raise "bad input #{child}"
          end
        end
      end
    end
  end
end
