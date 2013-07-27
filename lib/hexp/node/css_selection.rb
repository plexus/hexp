module Hexp
  class Node
    class CssSelection < Selector
      attr_reader :comma_sequence
      private :comma_sequence

      def initialize(node, css_selector)
        @node = node

        if css_selector.is_a? CssSelector::CommaSequence
          @comma_sequence = css_selector
        else
          @comma_sequence = CssSelector::Parser.call(css_selector)
        end
      end

      def node_matches?
        comma_sequence.members.any? do |sequence|
          sequence.members.count == 1 &&
            node_matches_SimpleSequence(sequence.members.first)
        end
      end

      # returns a new commasequence with the parts removed that have been consumed by matching
      # against this node. If no part matches, return nil
      def next_comma_sequence
        @next_comma_sequence = CssSelector::CommaSequence.new(comma_sequence.members.flat_map do |seq|
            if node_matches_SimpleSequence(seq.members.first)
              [seq, CssSelector::SimpleSequence.new(seq.members.drop(1))]
            else
              [seq]
            end
          end.reject {|seq| seq.members.count == 0}
        )
      end

      def each(&block)
        return to_enum(:each) unless block_given?

        @node.children.each do |child|
          self.class.new(child, next_comma_sequence).each(&block)
        end
        yield @node if node_matches?
      end

      def node_matches_SimpleSequence(simple_sequence)
        simple_sequence.members.all? do |simple|
          node_matches_Simple(simple)
        end
      end

      def node_matches_Simple(simple)
        case simple
        when CssSelector::Element             # span
          simple.name == @node.tag.to_s
        when CssSelector::Class                 # .foo
          @node.class?(simple.name)

          # when ::Sass::Selector::Id                  # #main
          # when ::Sass::Selector::Universal           # *
          # when ::Sass::Selector::Parent              # & in Sass
          # when ::Sass::Selector::Interpolation       # #{} in Sass
          # when ::Sass::Selector::Attribute           # [href^="http://"]
          # when ::Sass::Selector::Pseudo              # :visited, ::first-line, :nth-child(2n+1)
          # when ::Sass::Selector::SelectorPseudoClass # :not(.foo)
        else
          raise "CSS selectors containing #{simple.class} are not implemented in Hexp"
        end
      end
    end
  end
end
