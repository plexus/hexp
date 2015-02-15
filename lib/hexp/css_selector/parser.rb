module Hexp
  module CssSelector
    # A parser of CSS selectors
    #
    # This is a wrapper around the SASS parser. This way we are isolated from
    # changes in SASS. It also makes things easier should we decide to switch
    # to a different parsing library or roll our own parser. We only use a
    # fraction of the functionality of SASS so this might be worth it, although
    # at this point I want to avoid reinventing that wheel.
    #
    # The classes that make up the parse tree largely mimic the ones from SASS,
    # like CommaSequence, SimpleSequence, Class, Id, etc. By having them in our
    # own namespace however we can easily add Hexp-specific functionality to them.
    #
    class Parser
      # Initialize the parser with the selector to parse
      #
      # @param [String] selector
      #
      # @api private
      def initialize(selector)
        @selector = selector.freeze
      end

      # Parse the selector
      #
      # @return [Hexp::CssSelector::CommaSequence]
      #
      # @api private
      def parse
        CommaSequence.new(
          ::Nokogiri::CSS.parse(@selector).map do |node|
            node.accept(self)
          end
        )
      end

      # Parse a CSS selector in one go
      #
      # @param [String] selector
      # @return [Hexp::CssSelector::CommaSequence]
      #
      # @api private
      def self.call(selector)
        new(selector).parse
      end

      def visit_descendant_selector(node)
        Sequence.new(
          node.value.map {|child| child.accept(self) }
        )
      end

      def visit_conditional_selector(node)
        head, tail = node.value
        children = [head]
        while tail.type == :COMBINATOR
          head, tail = tail.value
          children << head
        end
        children << tail

        SimpleSequence.new(
          children.map {|child| child.accept(self) }
        )
      end

      def visit_element_name(node)
        if node.value == ["*"]
          Universal.new
        else
          Element.new(node.value.first)
        end
      end

      def visit_class_condition(node)
        Class.new(node.value.first)
      end

      def visit_id(node)
        Id.new(node.value.first.sub(/^#/, ''))
      end

      # ul > li
      def visit_child_selector(node)
        raise "not implemented"
      end

      # [href^="http://"]
      def visit_attribute_condition(node)
        element, operator, value = node.value
        name = element.value.first
        Attribute.new(name.sub(/^@/, ''), operator, value)
      end

      # li:first / li:nth-child(3n)
      def visit_pseudo_selector(node)
        raise "not implemented"
      end

    end
  end
end
