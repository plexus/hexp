module Hexp
  # A Hexp Node, or simply 'a hexp'
  class Node
    include Equalizer.new(:tag, :attributes, :children)
    extend Forwardable

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

    # Is this node an empty node
    #
    # H[:p, class: 'foo'].empty? #=> true
    # H[:p, [H[:span]].empty?    #=> false
    #
    # @return [Boolean] true if this node has no children
    # @api public
    #
    def_delegators :@children, :empty?

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
      @tag, @attributes, @children = Hexp.deep_freeze(
        Normalize.new(args).call
      )
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
    def to_html
      to_dom.to_html
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
    def to_dom
      Domize.new(self).call
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
      self.class.inspect_name + [tag, attributes, children ].reject(&:empty?).inspect
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

    # Rewrite a node tree
    #
    # Since nodes are immutable, this is the main entry point for deriving nodes
    # from others.
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
    # @example
    #    tree.rewrite{|node| [] if node.tag == :script }
    #
    # Wrap each <input> tag into a <p> tag
    #
    # @example
    #    tree.rewrite do |node|
    #      if node.tag == :input
    #        [ H[:p, [ child ] ]
    #      end
    #    end
    #
    # @param blk [Proc] The rewrite action
    # @return [Hexp::Node] The rewritten tree
    # @api public
    #
    def rewrite(&blk)
      return to_enum(:rewrite) unless block_given?

      self.class.new(
        tag,
        attributes,
        rewrite_children(&blk)
      )
    end

    # Attribute getter/setter
    #
    # When called with one argument : return the attribute value with that name.
    # When called with two arguments : return a new Node with the attribute set.
    # When the second argument is nil : return a new Node with the attribute unset.
    #
    # @example
    #    H[:p, class: 'hello'].attr('class')       # => "hello"
    #    H[:p, class: 'hello'].attr('id', 'para1') # => H[:p, {"class"=>"hello", "id"=>"para1"}]
    #    H[:p, class: 'hello'].attr('class', nil)  # => H[:p]
    #
    # @return [String|Hexp::Node]
    # @api public
    #
    def attr(*args)
      arity     = args.count
      attr_name = args[0].to_s

      case arity
      when 1
        attributes[attr_name]
      when 2
        set_attr(*args)
      else
        raise ArgumentError, "wrong number of arguments(#{arity} for 1..2)"
      end
    end

    # Check for the presence of a class
    #
    # @example
    #   H[:span, class: "banner strong"].class?("strong") #=> true
    #
    # @param klz [String] the name of the class to check for
    # @return [Boolean] true if the class is present, false otherwise
    # @api public
    #
    def class?(klz)
      attr('class') && attr('class').split(' ').include?(klz)
    end

    private

    # Helper for rewrite
    #
    # @param blk [Proc] the block for rewriting
    # @return [Array<Hexp::Node>]
    # @api private
    #
    def rewrite_children(&blk)
      self.children.flat_map {|child| child.rewrite(&blk)   }
                   .flat_map do |child|
        response = blk.call(child, self)
        if response.respond_to? :to_hexp
          [ response.to_hexp ]
        elsif response.respond_to? :to_str
          [ response.to_str ]
        elsif response.respond_to? :to_ary
          if response.first.instance_of? Symbol
            [ response ]
          else
            response
          end
        elsif response.nil?
          [ child ]
        else
          raise FormatError, "invalid rewrite response : #{response.inspect}, expected #{self.class} or Array, got #{response.class}"
        end
      end
    end

    # Set an attribute, used internally by #attr
    #
    # @param name [String|Symbol]
    # @param value [String]
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
