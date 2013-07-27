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
    # own namespace however we can easily add Hexp-specific helper functions.
    #
    class Parser
      def initialize(selector)
        @selector = selector.freeze
      end

      def parse
        rewrite_comma_sequence(SassParser.call(@selector))
      end

      def self.call(selector)
        new(selector).parse
      end

      private

      def rewrite_comma_sequence(comma_sequence)
        CommaSequence.new(comma_sequence.members.map{|sequence| rewrite_sequence(sequence)})
      end

      def rewrite_sequence(sequence)
        Sequence.new(sequence.members.map{|simple_sequence| rewrite_simple_sequence(simple_sequence)})
      end

      def rewrite_simple_sequence(simple_sequence)
        SimpleSequence.new(simple_sequence.members.map{|simple| rewrite_simple(simple)})
      end

      def rewrite_simple(simple)
        case simple
        when ::Sass::Selector::Element             # span
          Element.new(simple.name.first)
        when ::Sass::Selector::Class               # .foo
          Class.new(simple.name.first)
        when ::Sass::Selector::Id                  # #main
          Id.new(simple.name.first)
        else
          raise "CSS selectors containing #{simple.class} are not implemented in Hexp"
        end

        # when ::Sass::Selector::Universal           # *
        # when ::Sass::Selector::Parent              # & in Sass
        # when ::Sass::Selector::Interpolation       # #{} in Sass
        # when ::Sass::Selector::Attribute           # [href^="http://"]
        # when ::Sass::Selector::Pseudo              # :visited, ::first-line, :nth-child(2n+1)
        # when ::Sass::Selector::SelectorPseudoClass # :not(.foo)

      end
    end
  end
end
