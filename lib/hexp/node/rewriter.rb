module Hexp
  class Node
    # Create a new Hexp node based on an existing node
    #
    # Rewriting in this case means iterating over the whole Hexp tree, and for
    # each element providing zero or more elements to replace it with.
    #
    class Rewriter
      include Hexp

      def initialize(node, block)
        @node, @block = node, block
      end

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
      # @param blk [Proc] the block for rewriting
      # @return [Array<Hexp::Node>]
      # @api private
      #
      def rewrite_children
        @node.children
          .flat_map {|child| child.rewrite &@block   }
          .flat_map {|child| coerce_rewrite_response(@block.(child.to_hexp, @node)) || [child] }
      end

      def coerce_rewrite_response(response)
        return nil if response.nil?

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
