module Hexp
  module Sass
    # A CSS Parser that only knows how to parse CSS selectors
    #
    class SelectorParser < ::Sass::SCSS::CssParser
      def initialize(selector)
        super(selector, '')
      end

      def parse
        init_scanner!
        result = selector_comma_sequence
        raise "Invalid CSS selector : unconsumed input #{@scanner.rest}" unless @scanner.eos?
        result
      end

      def self.call(selector)
        self.new(selector).parse
      end
    end
  end
end
