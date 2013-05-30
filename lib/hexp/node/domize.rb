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
          doc << domize(@raw, doc)
        end
      end

      private

      def domize(hexp, parent)
        dom::Node.new(hexp.tag.to_s, @doc).tap do |node|
          hexp.attributes.each do |key,value|
            node[key] = value
          end
          hexp.children.each do |child|
            if child.instance_of?(TextNode)
              node << dom::Text.new(child, @doc)
            else
              node << domize(child, node)
            end
          end
        end
      end

    end
  end
end
