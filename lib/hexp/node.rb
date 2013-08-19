module Hexp
  # A `Hexp::Node` represents a single element in a HTML syntax tree. It
  # consists of three parts : the {#tag}, the {#attributes} and the {#children}.
  #
  # Instances of `Hexp::Node` are immutable. Because of this all methods that
  # "alter" the node actually return a new instance, leaving the old one
  # untouched.
  #
  # @example Immutable nodes : the old one is untouched
  #   node = Hexp::Node.new(:div)
  #   node2 = node.add_class('items')
  #   p node  # => H[:div]
  #   p node2 # => H[:div, 'class' => 'items']
  #
  # The `Hexp::Node` constructor takes a `Symbol`, a `Hash` and an `Array` for
  # the {#tag}, {#attributes} and {#children} respectively. However the
  # attributes and children can each be ommitted if they are empty.
  #
  # If the node contains a single child node, then it is not necessary to wrap
  # that child node in an array. One can use `H[tag, attrs, children]` as a
  # shorthand syntax. Finally one can use {Hexp::build} to construct nodes using
  # Ruby blocks, not unlike the Builder or Nokogiri gems.
  #
  # @example Creating Hexp : syntax alternatives and optional parameters
  #   Hexp::Node.new(:div, class: 'foo')
  #   Hexp::Node.new(:div, {class: 'foo'}, "A text node")
  #   Hexp::Node.new(:div, {class: 'foo'}, ["A text node"])
  #   H[:div, {class: 'foo'}, H[:span, {class: 'big'}, "good stuff"]]
  #   H[:div, {class: 'foo'}, [
  #       H[:span, {class: 'big'}, "good stuff"],
  #       H[:a, {href: '/index'}, "go home"]
  #     ]
  #   ]
  #   Hexp.build { div.strong { "Hello, world!" } }
  #
  # Methods that read or alter the attributes Hash are defined in
  # {Hexp::Node::Attributes}. Methods that read or alter the list of child nodes
  # are defined in {Hexp::Node::Children}
  #
  # == CSS selectors
  #
  # When working with large trees of {Hexp::Node} objects, it is convenient to
  # be able to target specific nodes using CSS selector syntax. Hexp supports a
  # subset of the CSS 3 selector syntax, see {Hexp::Node::CssSelection} for info
  # on the supported syntax.
  #
  # For changing, replacing or removing specific nodes based on a CSS selector
  # string, see {Hexp::Node#replace}. To iterate over nodes, see
  # {Hexp::Node#select}.
  #
  class Node
    include Equalizer.new(:tag, :attributes, :children)
    extend Forwardable

    include Hexp::Node::Attributes
    include Hexp::Node::Children

    # The HTML tag of this node
    #
    # @example
    #   H[:p].tag #=> :p
    #
    # @return [Symbol]
    # @api public
    #
    attr_reader :tag

    # The attributes of this node
    #
    # @example
    #   H[:p, class: 'foo'].attributes #=> {'class' => 'foo'}
    #
    # @return [Hash<String, String>]
    # @api public
    #
    attr_reader :attributes

    # The child nodes of this node
    #
    # @example
    #   H[:p, [ H[:span], 'hello' ]].children
    #   #=> Hexp::List[ H[:span], Hexp::TextNode["hello"] ]
    #
    # @return [Hexp::List]
    # @api public
    #
    attr_reader :children

    # Main entry point for creating literal hexps
    #
    # At the moment this just redirects to #new, and since Hexp::Node is aliased
    # to H this provides a shorthand for the contructor,
    #
    # @example
    #   H[:span, {attr: 'value'}].
    #
    # Note that while the H[] form is part of the public API and expected to
    # remain, it's implementation might change. In particular H might become
    # a class or module in its own right, so it is recommended to only use
    # this method in its H[] form.
    #
    # @param args [Array] args a Hexp node components
    # @return [Hexp::Node]
    # @api public
    #
    def self.[](*args)
      new(*args)
    end

    # Normalize the arguments
    #
    # @param args [Array] args a Hexp node components
    # @return [Hexp::Node]
    #
    # @example
    #    Hexp::Node.new(:p, {'class' => 'foo'}, [[:b, "Hello, World!"]])
    #
    # @api public
    #
    def initialize(*args)
      @tag, @attributes, @children = Normalize.new(args).call
    end

    # Standard hexp coercion protocol, return self
    #
    # @example
    #   H[:p].to_hexp #=> H[:p]
    #
    # @return [Hexp::Node] self
    # @api public
    #
    def to_hexp
      self
    end

    # Serialize this node to HTML
    #
    # @example
    #   H[:html, [ H[:body, ["hello, world"] ] ]] .to_html
    #   # => "<html><body>hello, world</body></html>"
    #
    # @return [String]
    # @api public
    #
    def to_html(options = {})
      to_dom(options).to_html
    end

    # Convert this node into a Nokogiri Document
    #
    # @example
    #  H[:p].to_dom
    #  #=> #<Nokogiri::HTML::Document name="document"
    #        children=[#<Nokogiri::XML::DTD name="html">,
    #        #<Nokogiri::XML::Element name="p">]>
    #
    # @return [Nokogiri::HTML::Document]
    # @api private
    #
    def to_dom(options = {})
      Domize.new(self, options).call
    end

    # Return a string representation that is close to the literal form
    #
    # @example
    #   H[:p, {class: 'foo'}].inspect #=> "H[:p, {\"class\"=>\"foo\"}]"
    #
    # @return [String]
    # @api public
    #
    def inspect
      self.class.inspect_name + [tag, attributes, children].compact.reject(&:empty?).inspect
    end

    # Pretty print, a multiline representation with indentation
    #
    # @example
    #   H[:p, [[:span], [:div]]].pp # => "H[:p, [\n  H[:span],\n  H[:div]]]"
    #
    # @return [String]
    # @api public
    #
    def pp
      self.class::PP.new(self).call
    end

    # Is this a text node? Returns false
    #
    # @example
    #   H[:p].text? #=> false
    #
    # @return [FalseClass]
    # @api public
    #
    def text?
      false
    end

    def set_tag(tag)
      H[tag.to_sym, attributes, children]
    end

    # Replace nodes in a tree
    #
    # With a CSS selector string like `"form.checkout"` you specify the nodes
    # you want to operate on. These will be passed one by one into the block.
    # The block returns the {Hexp::Node} that will replace the old node, or it
    # can replace an `Array` of nodes to fill the place of the old node.
    #
    # Because of this you can add one or more nodes, or remove nodes by
    # returning an empty array.
    #
    # If the CSS selector is ommitted, then the whole tree is traversed, and
    # every node is passed to the block.
    #
    # @example Remove all script tags
    #   tree.replace('script') {|_| [] }
    #
    # @example Wrap each `<input>` tag into a `<p>` tag
    #   tree.replace('input') do |input|
    #     H[:p, input]
    #   end
    #
    # @param block [Proc] The rewrite action
    # @return [Hexp::Node] The rewritten tree
    # @api public
    #
    def rewrite(css_selector = nil, &block)
      return Rewriter.new(self, block) if css_selector.nil?
      CssSelection.new(self, css_selector).rewrite(&block)
    end
    alias :replace :rewrite

    def select(css_selector = nil, &block)
      if css_selector
        CssSelection.new(self, css_selector).each(&block)
      else
        Selector.new(self, block)
      end
    end

    # Run a number of processors on this node
    #
    # This is pure convenience, but it helps to conceptualize the "processor"
    # idea of a component (be it a lambda or other object), that responds to
    # call, and transform a {Hexp::Node} tree.
    #
    # @example
    #   hexp.process(
    #     ->(node) { node.replace('.section') {|node| H[:p, class: 'big', node]} },
    #     ->(node) { node.add_class 'foo' },
    #     InlineAssets.new
    #   )
    #
    # @param processors [Array<#call>]
    # @return [Hexp::Node]
    # @api public
    #
    def process(*processors)
      processors.empty? ? self : processors.first.(self).process(*processors.drop(1))
    end

    private

    # Set an attribute, used internally by #attr
    #
    # Setting an attribute to nil will delete it
    #
    # @param name [String|Symbol]
    # @param value [String|NilClass]
    # @return [Hexp::Node]
    #
    # @api private
    #
    def set_attr(name, value)
      if value.nil?
        new_attrs = {}
        attributes.each do |nam,val|
          new_attrs[nam] = val unless nam == name.to_s
        end
      else
        new_attrs = attributes.merge(name.to_s => value.to_s)
      end
      self.class.new(self.tag, new_attrs, self.children)
    end

    class << self

      # Returns the class name for use in creating inspection strings
      #
      # This will return "H" if H == Hexp::Node, or "Hexp::Node" otherwise.
      #
      # @return [String]
      # @api private
      #
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
