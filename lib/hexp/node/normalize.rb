module Hexp
  class Node
    # Normalize a node
    #
    class Normalize
      # Set a node to be normalized
      #
      # @param [Array] node A non-strict hexp
      #
      # @example
      #     Hexp::Node::Normalize.new([:p, {class:'foo'}])
      #
      # @api public
      def initialize(args)
        @raw = args
      end

      # Normalize to strict hexp nodes, cfr SPEC.md for details
      #
      # @return [Array] strict hexp node
      #
      # @api private
      def call
        [@raw.first, normalized_attributes, normalized_children]
      end

      private

      # Pulls the attributes hash out of a non-strict hexp
      #
      # @return [Hash] the attributes hash
      #
      # @api private
      def attributes
        attrs = @raw[1]
        return attrs if attrs.instance_of?(Hash)
        {}
      end

      # Returns the attributes hash with key and value converted to strings
      #
      # @return [Hash]
      #
      # @api private
      def normalized_attributes
        Hash[*
          attributes.flat_map do |key, value|
            [key, value].map(&:to_s)
          end
        ]
      end

      # Pulls the children list out of a non-strict hexp
      #
      # @return [Array] the list of child hexps, non-strict
      #
      # @api private
      def children
        children = @raw.drop(1)
        children = children.drop(1)      if children.first.instance_of?(Hash)
        children = children.first.to_ary if children.first.respond_to?(:to_ary)
        children
      end

      # Normalize the third element of a hexp node, the list of children
      #
      # @return [Array] list of normalized hexps
      #
      # @api private
      def normalized_children
        Hexp::List[* children ]
      end

      def self.coerce_node(node)
        case node
        when Hexp::Node, Hexp::TextNode
          node
        when String
          Hexp::TextNode.new(node)
        when ->(ch) { ch.respond_to? :to_hexp }
          response = node.to_hexp
          raise FormatError, "to_hexp must return a Hexp::Node, got #{response.inspect}" unless response.instance_of?(Hexp::Node) || response.instance_of?(Hexp::TextNode)
          response
        when Array
          Hexp::Node[*node]
        else
          raise FormatError, "Invalid value in Hexp literal : #{node.inspect} (#{node.class}) does not implement #to_hexp"
        end
      end
    end

  end
end
