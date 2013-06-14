module Hexp
  # A Hexp Node
  class Node
    include Equalizer.new(:tag, :attributes, :children)
    extend Forwardable

    attr_reader :tag, :attributes, :children
    def_delegators :@children, :empty?

    # Normalize the arguments
    #
    # @param args [Array] args a Hexp node
    # @return [Hexp::Node]
    #
    # @example
    #    Hexp::Node[:p, {'class' => 'foo'}, [[:b, "Hello, World!"]]]
    #
    # @api public
    def initialize(*args)
      @tag, @attributes, @children = Hexp.deep_freeze(
        Normalize.new(args).call
      )
    end

    def self.[](*args)
      new(*args)
    end

    def to_hexp
      self
    end

    def to_html
      to_dom.to_html
    end

    def to_dom
      Domize.new(self).call
    end

    def inspect
      self.class.inspect_name + [tag, attributes, children ].reject(&:empty?).inspect
    end

    def pp
      self.class::PP.new(self).call
    end

    # Rewrite a node tree. Since nodes are immutable, this is the main entry point
    # for deriving nodes from others.
    #
    # Rewrite will pass you each node in the tree, and expects something to replace
    # it with. A single node, multiple nodes, or no nodes (remove it).
    #
    # Rewrite will not pass in the root node, since rewrite always returns a single
    # node, so it doesn't allow you to replace the root node with zero or multiple
    # nodes.
    #
    # The block can take one or two parameters, the first being the node that is
    # being replaced, the second (optional) its parent. As a response the block
    # needs to return one of these
    #
    #  * a single Hexp::Node
    #  * a Hexp::NodeList, or Array of Hexp::Node
    #  * an Array representation of a Hexp::Node, [:tag, {attributes}, [children]]
    #  * nil
    #
    # The last case (returning nil) means "do nothing", it will simply keep the
    # currently referenced node where it is. This is very handy when you only want
    # to act on certain nodes, just return nothing if you want to do nothing.
    #
    # Some examples :
    #
    # Remove all script tags
    #
    #    tree.rewrite{|node| [] if node.tag == :script }
    #
    # Wrap each <input> tag into a <p> tag
    #
    #    tree.rewrite do |node|
    #      if node.tag == :input
    #        [ H[:p, [ child ] ]
    #      end
    #    end
    #
    # @param blk [Proc] The rewrite action
    # @return [Hexp::Node] The rewritten tree
    def rewrite(&blk)
      return to_enum(:rewrite) unless block_given?

      H[self.tag,
        self.attributes,
        self.children.flat_map {|child| child.rewrite(&blk)   }
                     .flat_map do |child|
          response = blk.call(child, self)
          if response.instance_of?(Hexp::Node)
            [ response ]
          elsif response.respond_to?(:to_ary)
            if response.first.instance_of?(Symbol)
              [ response ]
            else
              response
            end
          elsif response.nil?
            [ child ]
          else
            raise FormatError, "invalid rewrite response : #{response.inspect}, expected Hexp::Node or Array, got #{response.class}"
          end
        end
      ]
    end

    class << self
      def inspect_name
        if defined?(H) && H == self
          'H'
        else
          self.name
        end
      end
    end
  end
end
