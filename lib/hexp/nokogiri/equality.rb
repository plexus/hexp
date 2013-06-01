module Hexp
  module Nokogiri
    # Used in test to see if two Nokogiri objects have the same content,
    # i.e. are equivalent as far as we are concerned
    class Equality
      CLASSES = [
        ::Nokogiri::HTML::Document,
        ::Nokogiri::HTML::DocumentFragment,
        ::Nokogiri::XML::Document,
        ::Nokogiri::XML::Node,
        ::Nokogiri::XML::Text,
        ::Nokogiri::XML::Element,
        ::Nokogiri::XML::DocumentFragment,
        ::Nokogiri::XML::DTD,
      ]

      def initialize(this, that)
        @this, @that = this, that
        [this, that].each do |input|
          raise "#{input.class} is not a Nokogiri element." unless CLASSES.include?(input.class)
        end
      end

      def call
        [ equal_class?,
          equal_name?,
          equal_children?,
          equal_attributes?,
          equal_text? ].all?
      end

      def equal_class?
        @this.class == @that.class
      end

      def equal_name?
        @this.name == @that.name
      end

      def equal_children?
        return true unless @this.respond_to? :children
        @this.children.count == @that.children.count &&
          compare_children.all?
      end

      def compare_children
        @this.children.map.with_index do |child, idx|
          self.class.new(child, @that.children[idx]).call
        end
      end

      def equal_attributes?
        return true unless @this.respond_to? :attributes
        @this.attributes.keys.all? do |key|
          @this[key] == @that[key]
        end
      end

      def equal_text?
        return true unless @this.instance_of?(::Nokogiri::XML::Text)
        @this.text == @that.text
      end
    end
  end
end
