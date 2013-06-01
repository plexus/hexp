module Hexp
  # A Hexp Node
  class Node
    include Equalizer.new(:tag, :attributes, :children)
    extend Forwardable

    attr_reader :tag, :attributes, :children
    def_delegators :@children, :empty?

    # Normalize the arguments
    #
    # @param args [Array] args a Hexp node
    # @return [Hexp::Node]
    #
    # @example
    #    Hexp::Node[:p, {'class' => 'foo'}, [[:b, "Hello, World!"]]]
    #
    # @api public
    def initialize(*args)
      @tag, @attributes, @children = Hexp.deep_freeze(
        Normalize.new(args).call
      )
    end

    def self.[](*args)
      new(*args)
    end

    def to_hexp
      self
    end

    def to_html
      to_dom.to_html
    end

    def to_dom
      Domize.new(self).call
    end

    def inspect
      self.class.inspect_name + [
        tag,
        attributes.empty? ? nil : attributes,
        empty?   ? nil : children,
      ].compact.inspect
    end

    def to_a
      [tag, attributes, children]
    end

    def pp
      out = self.class.inspect_name
      out << "[#{tag.inspect}"
      out << (attributes.empty? ? ''  : (', ' + attributes.inspect))
      out << (empty?   ? ']' : (", [\n" + children.map{|child| child.pp }.join(",\n") + "]]"))
      out.lines.map.with_index{|line, idx| idx==0 ? line : "  " + line}.join
    end

    class << self
      def inspect_name
        if defined?(H) && H == self
          'H'
        else
          self.name
        end
      end
    end
  end
end
