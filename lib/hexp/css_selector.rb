module Hexp
  module CssSelector
    # Common behavior for parse tree nodes based on a list of members
    #
    module Members
      include Equalizer.new(:members)

      extend Forwardable
      def_delegator :@members, :empty?

      # Member nodes
      #
      attr_reader :members

      # Shared initializer for parse tree nodes with children (members)
      #
      def initialize(members)
        @members = Hexp.deep_freeze(members)
      end

      # Create a class level collection constructor
      #
      # @example
      #   CommaSequence[member1, member2]
      #
      # @param klass [Class]
      # @api private
      #
      def self.included(klass)
        def klass.[](*members)
          new(members)
        end
      end

      # Return a debugging representation
      #
      # @return [String]
      # @api private
      #
      def inspect
        "#{self.class.name.split('::').last}[#{self.members.map(&:inspect).join(', ')}]"
      end
    end

    # Common behavior for parse tree elements that have a name
    #
    module Named
      include Equalizer.new(:name)
      attr_reader :name

      def initialize(name)
        @name = name.freeze
      end

      def inspect
        "<#{self.class.name.split('::').last} name=#{name}>"
      end
    end

    # Top level parse tree node of a CSS selector
    #
    # Contains a number of {Sequence} objects
    #
    # For example : `span .big, a'
    #
    class CommaSequence
      include Members

      # def inspect
      #   members.map(&:inspect).join(', ')
      # end

      # Does any sequence in this comma sequence fully match the given element
      #
      # This method does not recurse, it only checks if any of the sequences in
      # this CommaSequence with a length of one can fully match the given
      # element.
      #
      # @param element [Hexp::Node]
      # @return [Boolean]
      #
      def matches?(element)
        members.any? do |sequence|
          sequence.members.count == 1 &&
            sequence.head_matches?(element)
        end
      end
    end

    # A single CSS sequence like 'div span .foo'
    #
    class Sequence

      include Members

      def head_matches?(element)
        members.first.matches?(element)
      end

      def drop_head
        self.class.new(members.drop(1))
      end

      # def inspect
      #   members.map(&:inspect).join(' ')
      # end
    end

    # A CSS sequence that relates to a single element, like 'div.caption:first'
    #
    class SimpleSequence
      include Members

      def matches?(element)
        members.all? do |simple|
          simple.matches?(element)
        end
      end

      # def inspect
      #   members.map(&:inspect).join
      # end
    end

    # A CSS element declaration, like 'div'
    class Element
      include Named

      def matches?(element)
        element.tag.to_s == name
      end

      # def inspect
      #   name
      # end
    end

    # A CSS class declaration, like '.foo'
    #
    class Class
      include Named

      def matches?(element)
        element.class?(name)
      end
    end

    # A CSS id declaration, like '#section-14'
    #
    class Id
      include Named

      def matches?(element)
        element.attr('id') == name
      end
    end

    class Attribute
      include Equalizer.new(:name, :namespace, :operator, :value, :flags)
      attr_reader :name, :namespace, :operator, :value, :flags

      def initialize(name, namespace, operator, value, flags)
        @name = name.freeze
        @namespace = namespace.freeze
        @operator = operator.freeze
        @value = value.freeze
        @flag = flags.freeze
      end

      def inspect
        "<#{self.class.name.split('::').last} name=#{name} namespace=#{namespace.inspect} operator=#{operator.inspect} value=#{value.inspect} flags=#{flags.inspect}>"
      end

      def matches?(element)
        return false unless element[name]
        attribute = element[name]

        case operator
          # CSS 2
        when nil
          true
        when '='  # exact match
          attribute == value
        when '~=' # space separated list contains
          attribute.split(' ').include?(value)
        when '|=' # equal to, or starts with followed by a dash
          attribute =~ /\A#{Regexp.escape(value)}(-|\z)/

          # CSS 3
        when '^=' # starts with
          attribute.index(value) == 0
        when '$=' # ends with
          attribute =~ /#{Regexp.escape(value)}\z/
        when '*=' # contains
          !!(attribute =~ /#{Regexp.escape(value)}/)

        else
          raise "Unknown operator : #{operator}"
        end
      end
    end
  end
end
