module Hexp
  class Node
    # Turn nodes into DOM objects
    class Domize
      DEFAULT_OPTIONS = {
        :include_doctype => true
      }.freeze

      # The resulting DOM Document
      #
      # @return [Nokogiri::HTML::Document]
      # @api private
      #
      attr_reader :dom

      # Instanitiate a Domizer
      #
      # @param hexp [Hexp::Node]
      # @param options [Hash] :include_doctype defaults to true
      # @api private
      #
      def initialize(hexp, options = {})
        @dom     = Hexp::DOM
        @raw     = hexp
        @options = DEFAULT_OPTIONS.merge(options).freeze
      end

      # Turn the hexp into a DOM
      #
      # @return [Nokogiri::HTML::Document]
      # @api private
      #
      def call
        @doc  = dom::Document.new
        @root = domize(@raw)
        @doc << @root

        if @options[:include_doctype]
          @doc
        else
          @root
        end
      end

      private

      # Turn a Hexp::Node into a Document
      #
      # @param hexp [Hexp::Node]
      # @return [Nokogiri::HTML::Document]
      # @api private
      #
      def domize(hexp)
        dom::Node.new(hexp.tag.to_s, @doc).tap do |node|
          set_attributes(node, hexp.attributes)
          set_children(node, hexp.children)
        end
      end

      # Set attributes on a DOM node
      #
      # @param node [Nokogiri::XML::Element]
      # @param attributes [Hash]
      # @return [void]
      # @api private
      #
      def set_attributes(node, attributes)
        attributes.each do |key,value|
          node[key] = value
        end
      end

      # Set children on the DOM node
      #
      # @param node [Nokogiri::XML::Element]
      # @param children [Hexp::List]
      # @return [void]
      # @api private
      #
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
