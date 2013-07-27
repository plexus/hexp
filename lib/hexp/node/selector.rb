module Hexp
  class Node
    # Select nodes from a Hexp tree
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
    class Selector
      include Enumerable

      def initialize(node, block)
        @node, @select_block = node, block
      end

      def rewrite(&block)
        @node.rewrite do |node, parent|
          if @select_block.(node)
            block.(node, parent)
          else
            [node]
          end
        end
      end

      def attr(name, value)
        rewrite do |node|
          node.attr(name, value)
        end
      end

      def wrap(tag, attributes = {})
        rewrite do |node|
          H[tag, attributes, [node]]
        end
      end

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
