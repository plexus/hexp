module Hexp
  class Node
    # Turn nodes into DOM objects
    class Domize
      attr_reader :dom

      def initialize(hexp, dom = Hexp::DOM)
        @raw = hexp
        @dom = dom
      end

      def call
        dom::Document.new.tap do |doc|
          @doc = doc
          doc << domize(@raw)
        end
      end

      private

      def domize(hexp)
        dom::Node.new(hexp.tag.to_s, @doc).tap do |node|
          set_attributes(node, hexp.attributes)
          set_children(node, hexp.children)
        end
      end

      def set_attributes(node, attributes)
        attributes.each do |key,value|
          node[key] = value
        end
      end

      def set_children(node, children)
        children.each do |child|
          if child.instance_of?(TextNode)
            node << dom::Text.new(child, @doc)
          else
            node << domize(child)
          end
        end
      end
    end
  end
end
