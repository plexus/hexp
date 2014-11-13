module Hexp
  module CssSelector
    # Common behavior for parse tree nodes based on a list of members
    #
    module Members
      include Equalizer.new(:members)
      include Adamantium

      extend Forwardable
      def_delegator :@members, :empty?

      # Member nodes
      #
      # @return [Array]
      #
      # @api private
      attr_reader :members

      # Shared initializer for parse tree nodes with children (members)
      #
      # @api private
      def initialize(members)
        @members = members
      end

      # Create a class level collection constructor
      #
      # @example
      #   CommaSequence[member1, member2]
      #
      # @param [Class] klass
      #
      # @api private
      def self.included(klass)
        super
        def klass.[](*members)
          new(members)
        end
      end

      # Return a debugging representation
      #
      # @return [String]
      #
      # @api private
      def inspect
        "#{self.class.name.split('::').last}[#{self.members.map(&:inspect).join(', ')}]"
      end
    end

    # Common behavior for parse tree elements that have a name
    #
    module Named
      include Equalizer.new(:name)

      # The name of this element
      #
      # @return [String]
      #
      # @api private
      attr_reader :name

      # Shared constructor that sets a name
      #
      # @param [String] name
      #   the name of the element
      #
      # @api private
      def initialize(name)
        @name = name.freeze
      end

      # Return a representation convenient for debugging
      #
      # @return [String]
      #
      # @api private
      def inspect
        "<#{self.class.name.split('::').last} name=#{name}>"
      end
    end

    # Top level parse tree node of a CSS selector
    #
    # Contains a number of {Sequence} objects
    #
    # For example : 'span .big, a'
    #
    class CommaSequence
      include Members

      # Does any sequence in this comma sequence fully match the given element
      #
      # This method does not recurse, it only checks if any of the sequences in
      # this CommaSequence with a length of one can fully match the given
      # element.
      #
      # @param [Hexp::Node] element
      #
      # @return [Boolean]
      #
      # @api private
      def matches?(element)
        members.any? do |sequence|
          sequence.members.count == 1 &&
            sequence.head_matches?(element)
        end
      end

      def matches_path?(path)
        members.any? do |sequence|
          sequence.matches_path?(path)
        end
      end
    end

    # A single CSS sequence like 'div span .foo'
    #
    class Sequence
      include Members

      # Does the first element of this sequence match the element
      #
      # @param [Hexp::Node] element
      #
      # @return [true, false]
      #
      # @api private
      def head_matches?(element)
        members.first.matches?(element)
      end

      # Warning: Highly optimized cryptic code
      def matches_path?(path)
        return false if path.length < members.length
        return false unless members.last.matches?(path.last)

        path_idx = path.length    - 2
        mem_idx  = members.length - 2

        until path_idx < mem_idx || mem_idx == -1
          if members[mem_idx].matches?(path[path_idx])
            mem_idx -= 1
          end
          path_idx -= 1
        end

        mem_idx == -1
      end

      # Drop the first element of this Sequence
      #
      # This returns a new Sequence, with one member less.
      #
      # @return [Hexp::CssSelector::Sequence]
      #
      # @api private
      def drop_head
        self.class.new(members.drop(1))
      end
    end

    # A CSS sequence that relates to a single element, like 'div.caption:first'
    #
    class SimpleSequence
      include Members

      # Does the element match all parts of this SimpleSequence
      #
      # @params [Hexp::Node] element
      #
      # @return [true, false]
      #
      # @api private
      def matches?(element)
        members.all? do |simple|
          simple.matches?(element)
        end
      end
    end

    # A CSS element declaration, like 'div'
    class Element
      include Named

      # Does the node match this element selector
      #
      # @param [Hexp::Node] element
      #
      # @return [true, false]
      #
      # @api private
      def matches?(element)
        element.tag.to_s == name
      end
    end

    # Match any element, '*'
    class Universal
      def matches?(element)
        true
      end
    end

    # A CSS class declaration, like '.foo'
    #
    class Class
      include Named

      # Does the node match this class selector
      #
      # @param [Hexp::Node] element
      #
      # @return [true, false]
      #
      # @api private
      def matches?(element)
        element.class?(name)
      end
    end

    # A CSS id declaration, like '#section-14'
    #
    class Id
      include Named

      # Does the node match this id selector
      #
      # @param [Hexp::Node] element
      #
      # @return [true, false]
      #
      # @api private
      def matches?(element)
        element.attr('id') == name
      end
    end

    # An attribute selector, like [href^="http://"]
    #
    # @!attribute [r] name
    #   @return [String] The attribute name
    # @!attribute [r] namespace
    #   @return [String]
    # @!attribute [r] operator
    #   @return [String] The operator that works on an attribute value
    # @!attribute [r] value
    #   @return [String] The value to match against
    # @!attribute [r] flags
    #   @return [String]
    #
    # @api private
    class Attribute
      include Equalizer.new(:name, :namespace, :operator, :value, :flags)

      attr_reader :name, :namespace, :operator, :value, :flags

      # Construct a new Attribute selector
      #
      # The attributes directly mimic those returned from the SASS parser, even
      # though we don't use all of them.
      #
      # @param [String] name
      #   Name of the attribute, like 'href'
      # @param [String] namespace
      #   unused
      # @param [nil, String] operator
      #   Operator like '~=', '^=', ... Use blank to simply test attribute
      #   presence.
      # @param [String] value
      #   Value to test for, operator dependent
      # @param [Object] flags
      #   unused
      #
      # @api private
      def initialize(name, namespace, operator, value, flags)
        @name      = name.freeze
        @namespace = namespace.freeze
        @operator  = operator.freeze
        @value     = value.freeze
        @flag      = flags.freeze
      end

      # Debugging representation
      #
      # @return [String]
      #
      # @api private
      def inspect
        "<#{self.class.name.split('::').last} name=#{name} namespace=#{namespace.inspect} operator=#{operator.inspect} value=#{value.inspect} flags=#{flags.inspect}>"
      end

      # Does the node match this attribute selector
      #
      # @param [Hexp::Node] element
      #   node to test against
      #
      # @return [true, false]
      #
      # @api private
      def matches?(element)
        return false unless element[name]
        attribute = element[name]

        # TODO: check the spec with regards to IDENTIFIERS vs STRINGS as value
        #       see if we can lett SASS parse the string instead of unwrapping
        #       it ourselves
        value = self.value
        value = $1.gsub('\"', '"') if value =~ /\A"?(.*?)"?\z/

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
