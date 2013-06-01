module Hexp
  class Node
    # Pretty-print a node and its contents
    class PP
      def initialize(node)
        @node = node
      end

      def call
        [
          @node.class.inspect_name,
          pp_tag,
          PP.indent(pp_attributes + pp_children).strip
        ].join
      end

      def pp_tag
        "[#{@node.tag.inspect}"
      end

      def pp_attributes
        attrs = @node.attributes
        return '' if attrs.empty?
        ', ' + attrs.inspect
      end

      def pp_children
        children = @node.children
        return ']' if children.empty?
        ", [\n#{ children.map(&:pp).join(",\n") }]]"
      end

      def self.indent(string, indent = 2)
        string.lines.map {|line|  " "*indent + line}.join
      end
    end
  end
end
