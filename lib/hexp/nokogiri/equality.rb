module Hexp
  module Nokogiri
    # Used in test to see if two Nokogiri objects have the same content,
    # i.e. are equivalent as far as we are concerned
    #
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

      # Create a new equality tester for two Nokogiri objects
      #
      # (see Hexp::Nokogiri::Equality::CLASSES for all possible objects that can
      # be passed in)
      #
      # @example
      #   doc = Nokogiri::HTML::Document.new
      #   this_node = Nokogiri::XML::Element.new("div", doc)
      #   that_node = Nokogiri::XML::Element.new("span", doc)
      #   Hexp::Nokogiri::Equality.new(this_node, that_node).call #=> false
      #
      # @param this [Object] The first object to compare
      # @param that [Object] The second object to compare
      #
      # @api public
      #
      def initialize(this, that)
        @this, @that = this, that
        [this, that].each do |input|
          raise "#{input.class} is not a Nokogiri element." unless CLASSES.include?(input.class)
        end
      end

      # Perform the comparison
      #
      # @return [Boolean]
      #
      # @api public
      #
      def call
        [ equal_class?,
          equal_name?,
          equal_children?,
          equal_attributes?,
          equal_text? ].all?
      end

      # Are the two elements instances of the same class
      #
      # @return [Boolean]
      #
      # @api public
      #
      def equal_class?
        @this.class == @that.class
      end

      # Do both elements have the same tag name
      #
      # @return [Boolean]
      #
      # @api public
      #
      def equal_name?
        @this.name == @that.name
      end

      # Do the elements under comparison have the same child elements
      #
      # @return [Boolean]
      #
      # @api public
      #
      def equal_children?
        return true unless @this.respond_to? :children
        @this.children.count == @that.children.count &&
          compare_children.all?
      end

      # Compare the child elements, assuming both elements respond_to? :children
      #
      # @return [Boolean]
      #
      # @api public
      #
      def compare_children
        @this.children.map.with_index do |child, idx|
          self.class.new(child, @that.children[idx]).call
        end
      end

      # Do the elements under comparison have the same attributes
      #
      # @return [Boolean]
      #
      # @api public
      #
      def equal_attributes?
        return true unless @this.respond_to? :attributes
        @this.attributes.keys.all? do |key|
          @this[key] == @that[key]
        end
      end

      # Compare the text of text elements
      #
      # If the elements are not of type Nokogiri::XML::Text, return true
      #
      # @return [Boolean]
      #
      # @api public
      #
      def equal_text?
        return true unless @this.instance_of?(::Nokogiri::XML::Text)
        @this.text == @that.text
      end
    end
  end
end
