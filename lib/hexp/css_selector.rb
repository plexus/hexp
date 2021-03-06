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
        members.any? do |member|
          case member
          when Sequence
            member.members.count == 1 && member.head_matches?(element)
          else
            member.matches?(element)
          end
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
          if members[mem_idx].respond_to?(:matches_path?)
            if members[mem_idx].matches_path?(path.take(path_idx+1))
              mem_idx -= 1
            end
          else
            if members[mem_idx].matches?(path[path_idx])
              mem_idx -= 1
            end
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

      def matches_path?(path)
        members.all? do |simple|
          if simple.respond_to?(:matches_path?)
            simple.matches_path?(path)
          else
            simple.matches?(path.last)
          end
        end
      end

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

      alias head_matches? matches?
    end

    # A CSS element declaration, like 'div'
    class Element
      include Named

      def matches_path?(path)
        matches?(path.last)
      end

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
      def self.new
        @@instance ||= super
      end

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
      include Equalizer.new(:name, :operator, :value)

      attr_reader :name, :operator, :value

      # Construct a new Attribute selector
      #
      # The attributes directly mimic those returned from the SASS parser, even
      # though we don't use all of them.
      #
      # @param [String] name
      #   Name of the attribute, like 'href'
      # @param [nil, String] operator
      #   Operator like '~=', '^=', ... Use blank to simply test attribute
      #   presence.
      # @param [String] value
      #   Value to test for, operator dependent
      #
      # @api private
      def initialize(name, operator, value)
        @name      = name.freeze
        @operator  = operator.freeze
        @value     = value.freeze
      end

      # Debugging representation
      #
      # @return [String]
      #
      # @api private
      def inspect
        "<#{self.class.name.split('::').last} name=#{name} operator=#{operator.inspect} value=#{value.inspect}>"
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

        value = self.value
        value = $1.gsub('\"', '"') if value =~ /\A"?(.*?)"?\z/

        case operator
          # CSS 2
        when nil
          true
        when :equal  # '=': exact match
          attribute == value
        when :includes # '~=': space separated list contains
          attribute.split(' ').include?(value)
        when :dash_match # '|=' equal to, or starts with followed by a dash
          attribute =~ /\A#{Regexp.escape(value)}(-|\z)/

          # CSS 3
        when :prefix_match #'^=': starts with
          attribute.index(value) == 0
        when :suffix_match # '$=': ends with
          attribute =~ /#{Regexp.escape(value)}\z/
        when :substring_match # '*=': contains
          !!(attribute =~ /#{Regexp.escape(value)}/)

        else
          raise "Unknown operator : #{operator}"
        end
      end
    end

    # :first-child, :nth-child(3n) etc.
    class PseudoClass
      include Equalizer.new(:value)
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def matches_path?(path)
        node = path[-1]
        parent = path[-2]

        value.all? do |pc|
          case pc
          when 'first-child'
            node.equal?(parent.children.first)
          when 'last-child'
            node.equal?(parent.children.last)
          when 'empty'
            node.children.empty?
          else
            raise "not implemented, :#{pc} pseudo-class"
          end
        end
      end
    end

  end
end
