module Hexp
  class Node
    # Select nodes using CSS selectors
    #
    # The main interface to this is {Hexp::Node#select}, although there's
    # nothing stopping you from using this class directly.
    #
    # This class is +Enumerable+, and calling {#each} without a block will give
    # you an +Enumerator+, so you have all Ruby's tasty list operations at your
    # disposal.
    #
    # Only a subset of the
    # {http://www.w3.org/TR/css3-selectors/ CSS 3 selector syntax}
    # is supported. Parsing a selector that contains unsupported elements
    # should raise an exception.
    #
    # * tag selector : +div+, +a+, +section+
    # * class selector : +.big+, +.user_profile+
    # * id selector : +#main_content+, +#sidebar+
    # * attribute selectors : +[href]+, +[class~=foo]+, +[lang|=en]+
    #
    # Attribute selectors support
    # {http://www.w3.org/TR/css3-selectors/#attribute-selectors all the operators of the CSS 3 spec}
    #, so have a look there for more details.
    #
    # Of course you can combine all these.
    #
    # @example
    #   link = H[:a, {class: 'foo bar', lang: 'fr-be', href: 'http://example.com'}, "Hello, World"]
    #   node = H[:div, {class: 'wrap'}, link]
    #   node.select('div.wrap a.foo.bar[lang|=fr][href^=http]') do |a|
    #     p a.text
    #   end
    #
    class CssSelection < Selection
      include Enumerable

      # Create a new CssSelection based on a root node and a selector
      #
      # The selector can be unparsed (a plain +String+), or parsed. This class
      # works recursively by passing a subset of the parsed selector to a subset
      # of the tree, hence why this matters.
      #
      # @param [Hexp::Node] node
      #   Root node of the tree
      #
      # @param [String,Hexp::CssSelector::CommaSequence] css_selector
      #   CSS selector
      #
      # @api public
      def initialize(node, css_selector)
        @node, @css_selector = node.to_hexp, css_selector.freeze
      end

      # Debugging representation
      #
      # @return [String]
      #
      # @api public
      def inspect
        "#<#{self.class} @node=#{@node.inspect} @css_selector=#{@css_selector.inspect} matches=#{node_matches?}>"
      end

      # Iterate over the nodes that match
      #
      # @yieldparam [Hexp::Node]
      #   Each matching node
      #
      # @return [Enumerator,CssSelection]
      #   Enumerator if no block is given, or self
      #
      # @api public
      def each(&block)
        return to_enum(:each) unless block_given?

        walk = MutableTreeWalk.new(@node)

        until walk.end?
          if comma_sequence.matches_path?(walk.path)
            yield walk.current
          end
          walk.next!
        end

        self
      end

      # Replace / alter each node that matches
      #
      # @yieldparam [Hexp::Node]
      #   Each matching node
      #
      # @return [Hexp::Node]
      #
      # @api private
      def rewrite(&block)
        return @node if @node.text?

        walk = MutableTreeWalk.new(@node)

        until walk.end?
          if comma_sequence.matches_path?(walk.path)
            walk.replace!(block.call(walk.current))
          end
          walk.next!
        end

        walk.result
      end

      private

      # The CSS selector, parsed to a comma sequence
      #
      # @return [Hexp::CssSelector::CommaSequence]
      #
      # @api private
      def comma_sequence
        @comma_sequence ||= parse_selector
      end

      # Parse the CSS selector, if it isn't in a parsed form already
      #
      # @return [Hexp::CssSelector::CommaSequence]
      #
      # @api private
      def parse_selector
        return @css_selector if @css_selector.is_a? CssSelector::CommaSequence
        CssSelector::Parser.call(@css_selector)
      end

      # Is the current node part of the selection
      #
      # @return [true,false]
      #
      # @api private
      def node_matches?
        comma_sequence.matches?(@node)
      end

    end
  end
end
