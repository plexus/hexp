module Hexp
  class Node
    # Create a new Hexp node based on an existing node
    #
    # Rewriting in this case means iterating over the whole Hexp tree, and for
    # each element providing zero or more elements to replace it with.
    #
    class Rewriter
      include Hexp

      # Initialize a rewriter with the node to operate on, and the action
      #
      # @param [Hexp::Node] node
      #   The root node of the tree to be altered
      # @param [Proc] block
      #   The action to perform on each node
      #
      # @api public
      def initialize(node, block)
        @node, @block = node, block
      end

      # Implicit Hexp conversion protocol
      #
      # A {Rewriter} is lazy, only when one of the {Hexp::DSL} methods is used,
      # does the rewriting happen.
      #
      # @return [Hexp::Node]
      #
      # @api public
      def to_hexp
        @hexp ||= H[
          @node.tag,
          @node.attributes,
          @block ? rewrite_children : @node.children
        ]
      end

      private

      # Helper for rewrite
      #
      # @return [Array<Hexp::Node>]
      #
      # @api private
      def rewrite_children
        @node.children
          .flat_map {|child| child.rewrite(&@block)   }
          .flat_map {|child| coerce_rewrite_response(@block.(child.to_hexp, @node)) || [child] }
      end

      # Turn the response of a rewrite operation into something value
      #
      # The response can be a list of nodes, or a single node. If the response is
      # `nil`, that is interpreted as removing the node.
      #
      # @param [nil,#to_hexp,#to_str,#to_ary] response
      #
      # @return [Array<Hexp::Node>]
      #
      # @api private
      def coerce_rewrite_response(response)
        return [] if response.nil?

        return [response.to_hexp] if response.respond_to? :to_hexp
        return [response.to_str]  if response.respond_to? :to_str

        if response.respond_to? :to_ary
          return [response] if response.first.is_a? Symbol
          return response.to_ary
        end

        raise FormatError, "invalid rewrite response : #{response.inspect}, expected #{self.class} or Array, got #{response.class}"
      end
    end
  end
end
