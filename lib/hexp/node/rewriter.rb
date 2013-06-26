module Hexp
  class Node
    class Rewriter
      include Hexp

      def initialize(node, block)
        @node, @block = node, block
      end

      def to_hexp
        H[
          @node.tag,
          @node.attributes,
          rewrite_children
        ]
      end

      def attr(name, value)
        Rewriter.new(@node, ->(node, parent) { node = @block.(node, parent) ; node.attr(name, value) if node } )
      end

      def wrap(tag, attributes = {})
        Rewriter.new(@node, ->(node, parent) { node = @block.(node, parent) ; H[tag, attributes, [node]] if node } )
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
          .flat_map {|child| coerce_rewrite_response(@block.(child, @node)) || [child] }
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
