module Hexp
  module Nokogiri
    class Reader
      def call(node)
        return node.text if node.text?

        unless node.attributes.empty?
          attrs = node.attributes.map do |k,v|
            [k.to_sym, v.value]
          end
          attrs = Hash[attrs]
        end

        recurse = ->(node) { call(node) }
        H[node.name.to_sym, attrs, node.children.map(&recurse)]
      end
    end
  end
end
