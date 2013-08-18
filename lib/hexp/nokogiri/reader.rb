module Hexp
  module Nokogiri
    # Read Nokogiri, turning it into Hexp
    #
    class Reader
      # Take a Nokogiri root node and convert it to Hexp
      #
      # @param node [Nokogiri::XML::Element]
      # @return [Hexp::Node]
      # @api public
      #
      def call(node)
        return node.text if node.text?

        unless node.attributes.empty?
          attrs = node.attributes.map do |key, value|
            [key.to_sym, value.value]
          end
          attrs = Hash[attrs]
        end

        recurse = ->(node) { call(node) }
        H[node.name.to_sym, attrs, node.children.map(&recurse)]
      end
    end
  end
end
