module Hexp
  # Build Hexps using the builder pattern
  #
  class Builder < BasicObject
    include ::Hexp

    # def inspect
    #   ::Kernel.puts ::Kernel.caller ; ::Kernel.exit
    # end

    # Construct a new builder, and start building
    #
    # The recommended way to call this is through `Hexp.build`.
    #
    # @param tag [Symbol] The tag of the outermost element (optional)
    # @param args [Array<Hash|String>] Extra arguments, a String for a text
    #        node, a Hash for attributes
    # @param block [Proc] The block containing builder directives, can be with
    #        or without an argument.
    #
    # @api private
    #
    def initialize(tag = nil, *args, &block)
      @stack = []
      if tag
        tag!(tag, *args, &block)
      else
        _process(&block)
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
    # @param tag [Symbol] The tag name, like 'div' or 'head'
    # @param args [Array<Hash|String>] A hash of attributes, or a string to use
    #        inside the tag, or both. Multiple occurences of each can be
    #        specified
    # @param block [Proc] Builder directives for the contents of the tag
    # @return [NilClass]
    #
    # @api public
    #
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
      end
      nil
    end

    alias method_missing tag!

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
    # @params args [Array<:to_hexp>] Hexpable objects to add to the current tag
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
    # @return [Hexp::Node]
    # @api public
    #
    def to_hexp
      if @stack.empty?
        ::Kernel.raise ::Hexp::FormatError, "Hexp::Builder was called without a root element."
      end
      ::Hexp::Node[*@stack.last]
    end

    private

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
    # @return [NilClass]
    # @api private
    #
    def _process(&block)
      if block.arity == 1
        block.call(self)
      else
        self.instance_eval(&block)
      end
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
  end
end
