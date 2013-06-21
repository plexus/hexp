module Hexp
  class Node
    # Pretty-print a node and its contents
    class PP
      # Create a new pretty-printer
      #
      # @param node [Hexp::Node] The node to represent
      # @api private
      #
      def initialize(node)
        @node = node
      end

      # Perform the pretty-printing
      #
      # @return [String] The pp output
      # @api private
      #
      def call
        [
          @node.class.inspect_name,
          pp_tag,
          PP.indent(pp_attributes + pp_children).strip
        ].join
      end

      # Format the node tag
      #
      # @return [String]
      # @api private
      #
      def pp_tag
        "[#{@node.tag.inspect}"
      end

      # Format the node attributes
      #
      # @return [String]
      # @api private
      #
      def pp_attributes
        attrs = @node.attributes
        return '' if attrs.empty?
        ', ' + attrs.inspect
      end

      # Format the node children
      #
      # @return [String]
      # @api private
      #
      def pp_children
        children = @node.children
        return ']' if children.empty?
        ", [\n#{ children.map(&:pp).join(",\n") }]]"
      end

      # Indent a multiline string with a number of spaces
      #
      # @param string [String] The string to indent
      # @param indent [Integer] The number of spaces to use for indentation
      # @return [String]
      # @api private
      #
      def self.indent(string, indent = 2)
        string.lines.map {|line|  " "*indent + line}.join
      end
    end
  end
end
