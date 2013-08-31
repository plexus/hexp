module Hexp
  # Build Hexps using the builder pattern
  #
  class Builder < BasicObject
    include ::Hexp

    # Construct a new builder, and start building
    #
    # The recommended way to call this is through `Hexp.build`. If the block
    # takes an argument, then builder methods need to be called on that variable.
    #
    # @example With an explicit builder
    #   hi = Hexp.build {|html| html.span "Hello" ; html.span " World"}
    #
    # @example Without a builder object
    #   hi = Hexp.build { span "Hello" ; span " World"}
    #
    # @param [Symbol] tag
    #   The tag of the outermost element (optional)
    # @param [Array<Hash,String>] args
    #   Extra arguments, a String for a text node, a Hash for attributes
    #
    # @yieldparam [Hexp::Builder]
    #   If the block takes an argument it will receive the builder object
    #
    # @api private
    #
    def initialize(tag = nil, *args, &block)
      @stack = []
      if tag
        tag!(tag, *args, &block)
      else
        _process(&block) if block
      end
    end

    # Add a tag (HTML element)
    #
    # Typically this is called implicitly through method missing, but in case of
    # name clashes or dynamically generated tags you can call this directly.
    #
    # @example
    #   hexp = Hexp.build :div do
    #     tag!(:p, "Oh the code, such sweet joy it brings")
    #   end
    #   hexp.to_html #=> "<div><p>Oh the code, such sweet joy it brings</p></div>"
    #
    # @param [Symbol] tag
    #   The tag name, like 'div' or 'head'
    # @param [Array<Hash|String>] args
    #   A hash of attributes, or a string to use inside the tag, or both. Multiple
    #   occurences of each can be specified
    # @param [Proc] block
    #   Builder directives for the contents of the tag
    #
    # @return [nil]
    #
    # @api public
    def tag!(tag, *args, &block)
      text, attributes = nil, {}
      args.each do |arg|
        case arg
        when ::Hash
          attributes.merge!(arg)
        when ::String
          text ||= ''
          text << arg
        end
      end
      @stack << [tag, attributes, text ? [text] : []]
      if block
        _process(&block)
      end
      if @stack.length > 1
        node = @stack.pop
        @stack.last[2] << node
        NodeBuilder.new(node, self)
      else
        NodeBuilder.new(@stack.last, self)
      end
    end

    alias method_missing tag!

    # Add a text node to the tree
    #
    # @example
    #   hexp = Hexp.build do
    #     span do
    #       text! 'Not all who wander are lost'
    #     end
    #   end
    #
    # @param [String] text
    #   the text to add
    #
    # @return [Hexp::Builder] self
    #
    # @api public
    def text!(text)
      _raise_if_empty! "Hexp::Builder needs a root element to add text elements to"
      @stack.last[2] << text.to_s
      self
    end

    # Add Hexp objects to the current tag
    #
    # Any Hexp::Node or other object implementing to_hexp can be added with
    # this operator. Multiple objects can be specified in one call.
    #
    # Nokogiri and Builder allow inserting of strings containing HTML through
    # this operator. Since this would violate the core philosophy of Hexp, and
    # open the door for XSS vulnerabilities, we do not support that usage.
    #
    # If you really want to insert HTML that is already in serialized form,
    # consider parsing it to Hexps first
    #
    # @example
    #   widget = H[:button, "click me!"]
    #   node = Hexp.build :div do |h|
    #     h << widget
    #   end
    #   node.to_html #=> <div><button>click me!</button></div>
    #
    # @param [Array<#to_hexp>] args
    #   Hexpable objects to add to the current tag
    #
    # @return [Hexp::Builder]
    #
    # @api public
    #
    def <<(*args)
      args.each do |arg|
        if arg.respond_to?(:to_hexp)
          @stack.last[2] << arg
          self
        else
          ::Kernel.raise ::Hexp::FormatError, "Inserting literal HTML into a builder with << is deliberately not supported by Hexp"
        end
      end
    end

    # Implement the standard Hexp coercion protocol
    #
    # By implementing this a Builder is interchangeable for a regular node, so
    # you can use it inside other nodes transparently. But you can call this
    # method if you really, really just want the plain {Hexp::Node}
    #
    # @example
    #  Hexp.build { div { text! 'hello' } }.to_hexp # => H[:div, ["hello"]]
    #
    # @return [Hexp::Node]
    #
    # @api public
    def to_hexp
      _raise_if_empty!
      ::Hexp::Node[*@stack.last]
    end

    # Call the block, with a specific value of 'self'
    #
    # If the block takes an argument, then we pass ourselves (the builder) to
    # the block, and call it as a closure. This way 'self' refers to the calling
    # object, and it can reference its own methods and ivars.
    #
    # If the block does not take an argument, then we evaluate it in the context
    # of ourselves (the builder), so unqualified method calls are seen as
    # builder calls.
    #
    # @param block [Proc]
    #
    # @return [nil]
    #
    # @api private
    def _process(&block)
      if block.arity == 1
        block.call(self)
      else
        self.instance_eval(&block)
      end
    end

    # Allow setting HTML classes through method calls
    #
    # @example
    #   Hexp.build do
    #     div.miraculous.wondrous do
    #       hr
    #     end
    #   end
    #
    # @api private
    class NodeBuilder
      # Create new NodeBuilder
      #
      # @param [Array] node
      #   (tag, attrs, children) triplet
      # @param [Hexp::Builder] builder
      #   The parent builder to delegate back
      #
      # @api private
      def initialize(node, builder)
        @node, @builder = node, builder
      end

      # Used for specifying CSS class names
      #
      # @example
      #   Hexp.build { div.strong.warn }.to_hexp
      #   # => H[:div, class: 'strong warn']
      #
      # @param [Symbol] sym
      #   the class to add
      #
      # @return [Hexp::Builder::NodeBuilder] self
      #
      # @api public
      def method_missing(sym, &block)
        attrs = @node[1]
        @node[1] = attrs.merge class: [attrs[:class], sym.to_s].compact.join(' ')
        @builder._process(&block) if block
        self
      end
    end

    # Return a debugging representation
    #
    # Hexp is intended for HTML, so it shouldn't be a problem that this is an
    # actual method. It really helps for debugging or when playing around in
    # irb. If you really want an `<inspect>` tag, use `tag!(:inspect)`.
    #
    # @example
    #   p Hexp.build { div }
    #
    # @return [String]
    #
    # @api public
    def inspect
      "#<Hexp::Builder #{@stack.empty? ? '[]' : to_hexp.inspect}>"
    end

    # Gratefully borrowed from Builder.
    # I'd like to benchmark this singleton class based version vs
    # adding the methods to the class directly, before putting this in.
    #
    # @param sym [Symbol] Name of the method to define
    # @api private
    #
    # def _cache_method_call(sym)
    #   class << self; self; end.class_eval do
    #     unless method_defined?(sym)
    #       define_method(sym) do |*args, &block|
    #         tag!(sym, *args, &block)
    #       end
    #     end
    #   end
    # end

    private

    # Raise an exception if nothing has been built yet
    #
    # @param [String] text
    #   The error message
    #
    # @raise [Hexp::FormatError]
    #   if the builder is converted to a {Hexp::Node} before a root element is
    #   defined.
    #
    # @api private
    def _raise_if_empty!(text = 'Hexp::Builder is lacking a root element.')
      ::Kernel.raise ::Hexp::FormatError, text if @stack.empty?
    end
  end
end
