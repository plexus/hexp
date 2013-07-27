module Hexp
  class Node
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

        @node.rewrite do |node|
          yield node if @select_block.(node)
        end
      end
    end
  end
end
