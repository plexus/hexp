module Hexp
  class Node
    # Node API methods that deal with child_nodes
    #
    module Children
      # Is this node an empty node
      #
      # H[:p, class: 'foo'].empty? #=> true
      # H[:p, [H[:span]].empty?    #=> false
      #
      # @return [Boolean] true if this node has no children
      # @api public
      #
      def empty?
        children.empty?
      end

      def add_child(child)
        H[
          self.tag,
          self.attributes,
          self.children + [child]
        ]
      end
      alias :add :add_child
      alias :<< :add_child

      def text
        children.map do |node|
          node.text? ? node : node.text
        end.join
      end

      def set_children(new_children)
        H[tag, attributes, new_children]
      end

      def map_children(&blk)
        H[tag, attributes, children.map(&blk)]
      end
    end
  end
end
