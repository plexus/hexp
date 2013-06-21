module Hexp
  # Represents text inside HTML. Instances behave like Strings, but also support
  # the most of `Hexp::Node` interface, so you don't have to treat them differently
  # when traversing across trees.
  #
  # Strings used inside Hexp literals like `H[:span, "Hi!"]` automatically get
  # converted to `TextNode` instances, so there is usually no reason to instantiate
  # these yourself.
  class TextNode < SimpleDelegator
    # Inspect the TextNode, this delegates to the underlying String, making it
    # non-obvious that you're dealing with something else. However, a TextNode
    # supports the full API of String, so this might not be a big problem.
    # The benefit is that inspection of complete nodes containing text looks
    # nice
    #
    # @example
    #   Hexp::TextNode.new("hello, world").inspect #=> "\"hello, world\""
    #
    # @return [String]
    # @api public
    #
    def inspect
      __getobj__.inspect
    end

    # The attributes of this Node. Text nodes can not have attributes, so this
    # always returns an empty Hash
    #
    # @return [Hash]
    # @api public
    #
    def attributes
      {}.freeze
    end

    # Same as inspect, used by `Hexp::Node#pp`.
    #
    # @example
    #   Hexp::TextNode.new("hello, world").pp #=> "\"hello, world\""
    #
    # @return [String]
    # @api public
    #
    def pp
      inspect
    end

    # The tag of this node. A text node does not have a tag, so this returns nil
    #
    # @example
    #   Hexp::TextNode.new("hello, world").tag #=> nil
    #
    # @return [NilClass]
    # @api public
    #
    def tag
    end

    # Attribute combined getter/setter. Text nodes don't have attributes, so
    # when used as a getter this returns nil. When used as a setter this will
    # raise an exception, since it's not possible to set attributes on a text
    # node.
    #
    # @example
    #   Hexp::TextNode.new("hello, world").attr('foo') #=> nil
    #   Hexp::TextNode.new("hello, world").attr('class', 'big') #=> IllegalRequestError
    #
    # @return [NilClass]
    # @api public
    #
    def attr(*args)
      arity = args.count
      case arity
      when 1
        nil
      when 2
        raise IllegalRequestError, "Setting attributes on a Hexp::TextNode is not allowed"
      else
        raise ArgumentError, "wrong number of arguments(#{arity} for 1..2)"
      end
    end

    # Standard conversion protocol, returns self.
    #
    # @example
    #   Hexp::TextNode.new("hello, world").to_hexp #=> #<Hexp::TextNode "hello, world">
    #
    # @return [Hexp::TextNode]
    # @api public
    #
    def to_hexp
      self
    end

    # Children of the node. A text node has no children, this always returns an empty
    # array.
    #
    # @example
    #   Hexp::TextNode.new("hello, world").children #=> []
    #
    # @return [Array]
    # @api public
    #
    def children
      [].freeze
    end

    # Is this a text node?
    #
    # @example
    #   Hexp::TextNode.new('foo').text? #=> true
    #   H[:p].text? #=> false
    #
    # @return [TrueClass]
    # @api public
    #
    def text?
      true
    end

    # Is a certain CSS class present on this node? Text nodes have no attributes, so
    # this always returns false.
    #
    # @example
    #   Hexp::TextNode.new('foo').class?('bar') #=> false
    #
    # @return [FalseClass]
    # @api public
    #
    def class?(klz)
      false
    end

    # Rewrite a node. See Hexp::Node#rewrite for more info. On a TextNode this simply
    # return self.
    #
    # @example
    #   tree.rewrite do |node|
    #     H[:div, {class: 'wrap'}, node]
    #   end
    #
    # @return [Hexp::TextNode]
    # @api public
    #
    def rewrite(&blk)
      self
    end
  end
end
