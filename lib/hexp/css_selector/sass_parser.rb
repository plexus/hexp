module Hexp
  module CssSelector
    # A CSS Parser that only knows how to parse CSS selectors
    #
    class SassParser < ::Sass::SCSS::CssParser
      # Initialize the parser with the selector to parse
      #
      # @param [String] selector
      #
      # @api private
      def initialize(selector)
        super(selector, '')
      end

      # Parse the selector
      #
      # @return [Sass::Selector::CommaSequence]
      #
      # @api private
      def parse
        init_scanner!
        result = selector_comma_sequence
        raise "Invalid CSS selector : unconsumed input #{@scanner.rest}" unless @scanner.eos?
        result
      end

      # Parse a CSS selector in one go
      #
      # @param [String] selector
      # @return [Sass::Selector::CommaSequence]
      #
      # @api private
      def self.call(selector)
        self.new(selector).parse
      end
    end
  end
end
