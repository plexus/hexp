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
    class CssSelection < Selector
      include Enumerable

      # Create a new CssSelection based on a root node and a selector
      #
      # The selector can be unparsed (a plain +String+), or parsed. This class
      # works recursively by passing a subset of the parsed selector to a subset
      # of the tree, hence why this matters.
      #
      # @param node [Hexp::Node] Root node of the tree
      # @param css_selector [String,Hexp::CssSelector::CommaSequence] CSS selector
      # @api public
      #
      def initialize(node, css_selector)
        @node, @css_selector = node.to_hexp, css_selector.freeze
      end

      # Debugging representation
      #
      # @return [String]
      # @api public
      #
      def inspect
        "#<#{self.class} @node=#{@node.inspect} @css_selector=#{@css_selector.inspect} matches=#{node_matches?}>"
      end

      # Iterate over the nodes that match
      #
      # @param block [Proc] a block that receives each matching nodes
      # @return [Enumerator,CssSelection] enumerator if no block is given, or self
      def each(&block)
        return to_enum(:each) unless block_given?

        @node.children.each do |child|
          next_selection_for(child).each(&block)
        end
        yield @node if node_matches?
        self
      end

      # Replace / alter each node that matches
      #
      # @api private (might still take this out)
      #
      def rewrite(&block)
        return @node if @node.text?

        new_node = H[
          @node.tag,
          @node.attributes,
          @node.children.flat_map do |child|
            next_selection_for(child).rewrite(&block)
          end
        ]
        node_matches? ? block.call(new_node) : new_node
      end

      private

      def comma_sequence
        @comma_sequence ||= coerce_to_comma_sequence
      end

      def coerce_to_comma_sequence
        return @css_selector if @css_selector.is_a? CssSelector::CommaSequence
        CssSelector::Parser.call(@css_selector)
      end

      def node_matches?
        comma_sequence.matches?(@node)
      end

      # returns a new commasequence with the parts removed that have been consumed by matching
      # against this node. If no part matches, return nil
      def next_comma_sequence
        @next_comma_sequence ||= CssSelector::CommaSequence.new(consume_matching_heads)
      end

      def next_selection_for(child)
        self.class.new(child, next_comma_sequence)
      end

      def consume_matching_heads
        comma_sequence.members.flat_map do |sequence|
          if sequence.head_matches? @node
            [sequence, sequence.drop_head]
          else
            [sequence]
          end
        end.reject(&:empty?)
      end

    end
  end
end
