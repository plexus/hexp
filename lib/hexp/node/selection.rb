module Hexp
  class Node
    # Subset of nodes from a Hexp tree
    #
    # This is what is backing the {Hexp::Node#select} method. It serves a double
    # purpose. At it's core it's an Enumerable for iterating over nodes that
    # match a criterium.
    #
    # @example
    #   # Loop over the nodes with class="big"
    #   hexp.select {|el| el.class? 'big' }.each { ... }
    #
    # It also integrates with {Hexp::Node::Rewriter} for selective rewriting of
    # a Hexp tree.
    #
    # @example
    #   # stick all links inside a <span class="link> ... </span>
    #   hexp.select {|el| el.tag == 'a' }.wrap(:span, class: 'link')
    #
    class Selection
      include Enumerable

      # Initialize a selection with the root node, and the selection block used
      # as the filtering criterion
      #
      # @param [Hexp::Node] node
      #   The root of the tree to select in
      #
      # @param [Proc] block
      #   A block that for a given node returns a truthy or falsey value
      #
      # @api private
      def initialize(node, block)
        @node, @select_block = node, block
      end

      # Replace matching nodes
      #
      # Analogues to the main {Hexp::Node#rewrite} operation.
      #
      # @yieldparam [Hexp::Node]
      #
      # @return [Hexp::Node]
      #
      # @api public
      def rewrite(&block)
        @node.rewrite do |node, parent|
          if @select_block.(node)
            block.(node, parent)
          else
            node
          end
        end
      end

      # Set an attribute on all matching nodes
      #
      # @param [#to_s] name
      #   The attribute name
      # @param [#to_s] value
      #   The attribute value
      #
      # @return [Hexp::Node]
      #   The new tree
      #
      # @api public
      def attr(name, value)
        rewrite do |node|
          node.attr(name, value)
        end
      end

      # Wrap each matching node in a specific node
      #
      # @param [Symbol] tag
      #   The tag of the wrapping node
      # @paeam [Hash] attributes
      #   The attributes of the node
      #
      # @return [Hexp::Node]
      #   The new tree of nodes
      #
      # @api public
      def wrap(tag, attributes = {})
        rewrite do |node|
          H[tag, attributes, [node]]
        end
      end

      # Yield each matching node
      #
      # @yieldparam [Hexp::Node]
      #
      # @api public
      def each(&block)
        return to_enum(:each) unless block_given?

        @node.children.each do |child|
          child.select(&@select_block).each(&block)
        end
        yield @node if @select_block.(@node)
      end
    end
  end
end
