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
        rewrite_comma_sequence(SassParser.call(@selector))
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

      private

      # Map CommaSequence from the SASS namespace to our own
      #
      # @param [Sass::Selector::CommaSequence] comma_sequence
      # @return [Hexp::CssSelector::CommaSequence]
      #
      # @api private
      def rewrite_comma_sequence(comma_sequence)
        CommaSequence.new(comma_sequence.members.map{|sequence| rewrite_sequence(sequence)})
      end

      # Map Sequence from the SASS namespace to our own
      #
      # @param [Sass::Selector::Sequence] comma_sequence
      # @return [Hexp::CssSelector::Sequence]
      #
      # @api private
      def rewrite_sequence(sequence)
        Sequence.new(sequence.members.map{|simple_sequence| rewrite_simple_sequence(simple_sequence)})
      end

      # Map SimpleSequence from the SASS namespace to our own
      #
      # @param [Sass::Selector::SimpleSequence] comma_sequence
      # @return [Hexp::CssSelector::SimpleSequence]
      #
      # @api private
      def rewrite_simple_sequence(simple_sequence)
        SimpleSequence.new(simple_sequence.members.map{|simple| rewrite_simple(simple)})
      end

      # Map Simple from the SASS namespace to our own
      #
      # @param [Sass::Selector::Simple] comma_sequence
      # @return [Hexp::CssSelector::Simple]
      #
      # @api private
      def rewrite_simple(simple)
        case simple
        when ::Sass::Selector::Element             # span
          Element.new(simple.name.first)
        when ::Sass::Selector::Class               # .foo
          Class.new(simple.name.first)
        when ::Sass::Selector::Id                  # #main
          Id.new(simple.name.first)
        when ::Sass::Selector::Attribute           # [href^="http://"]
          raise "CSS attribute selector flags are curently ignored by Hexp (not implemented)" unless simple.flags.nil?
          raise "CSS attribute namespaces are curently ignored by Hexp (not implemented)" unless simple.namespace.nil?
          raise "CSS attribute operator #{simple.operator} not understood by Hexp" unless %w[= ~= ^= |= $= *=].include?(simple.operator) || simple.operator.nil?
          Attribute.new(
            simple.name.first,
            simple.namespace,
            simple.operator,
            simple.value ? simple.value.first : nil,
            simple.flags
          )
        else
          raise "CSS selectors containing #{simple.class} are not implemented in Hexp"
        end

        # As of yet unimplemented
        # when ::Sass::Selector::Universal           # *
        # when ::Sass::Selector::Parent              # & in Sass
        # when ::Sass::Selector::Interpolation       # #{} in Sass
        # when ::Sass::Selector::Pseudo              # :visited, ::first-line, :nth-child(2n+1)
        # when ::Sass::Selector::SelectorPseudoClass # :not(.foo)

      end
    end
  end
end
