module Hexp
  class Node
    # Node API methods that deal with child_nodes
    #
    module Children
      # Is this node an empty node
      #
      # @example
      #   H[:p, class: 'foo'].empty? #=> true
      #   H[:p, [H[:span]].empty?    #=> false
      #
      # @return [true,false]
      #   True if this node has no children
      #
      # @api public
      def empty?
        children.empty?
      end

      # Add a child node to the end of the list of children
      #
      # @example
      #   H[:ul].add_child(H[:li, "chunky"]) #=> H[:ul, [H[:li, "chunky]]]
      #
      # @param [Hexp::Node] child
      #   The child node to add
      #
      # @return [Hexp::Node]
      #   A new node containing that has the child added to its children
      #
      # @api public
      def add_child(child)
        H[
          self.tag,
          self.attributes,
          self.children + [child]
        ]
      end
      alias :add :add_child
      alias :<< :add_child

      # All the text in this node and its descendants
      #
      # Concatenates the contents of all text nodes.
      #
      # @example
      #   H[:div, [
      #       H[:span, "My name is"],
      #       " ",
      #       H[:strong, "@plexus"],
      #       "."
      #     ]
      #   ].text #=> "My name is @plexus."
      #
      # @return [String]
      #
      # @api public
      def text
        children.map do |node|
          node.text? ? node : node.text
        end.join
      end

      # Replace the children of this node with a new list of children
      #
      # @example
      #   H[:div, "Hello"].set_children([H[:span, "wicked!"], H[:br]])
      #   # => H[:div, [H[:span, "wicked!"], H[:br]]]
      #
      # @param [Array,Hexp::NodeList] new_children
      #
      # @return [Hexp::Node]
      #
      # @api public
      def set_children(new_children)
        H[tag, attributes, new_children]
      end

      # Perform an action on each child node, and replace the node with the result
      #
      # @example
      #   H[:div, [H[:span, "foo"]]].map_children do |node|
      #     node.add_class(node.text)
      #   end
      #   # => H[:div, [H[:span, {class: "foo"}, "foo"]]]
      #
      # @yieldparam [Hexp::Node]
      #   The child node
      #
      # @return [Hexp::Node]
      #
      # @api public
      def map_children(&blk)
        return to_enum(:map_children) unless block_given?
        H[tag, attributes, children.map(&blk)]
      end
    end
  end
end
