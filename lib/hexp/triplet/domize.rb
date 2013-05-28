module Hexp
  class Triplet
    # Turn triplets into DOM objects
    class Domize
      attr_reader :dom

      def initialize(triplet, dom = Hexp::DOM)
        @raw = triplet
        @dom = dom
      end

      def call
        dom::Document.new.tap do |doc|
          @doc = doc
          doc << domize(@raw, doc)
        end
      end

      private

      def domize(triplet, parent)
        dom::Node.new(triplet.tag.to_s, @doc).tap do |node|
          triplet.attributes.each do |key,value|
            node[key] = value
          end
          triplet.children.each do |child|
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
